//
//  BrazeApplicationService.swift
//  Knowledge
//
//  Created by Elmar Tampe on 21.04.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import BrazeKit
import UIKit
import Domain
import Networking
import DateToolsSwift
import DIKit

/// @mockable
protocol BrazeApplicationServiceType: ApplicationService {
    var client: Braze? { get }
    var isLoginTrackingNeeded: Bool { get }
    var isEnabled: Bool { get set }

    func identify(id: String, email: String)
    func reset()
    func refreshContentCards()

    func storeDismissalDate()
    func conditionallyLogImpression(for card: BrazeContentCard)

    #if DEBUG || QA
    var forcedCards: [BrazeContentCard] { get set }
    #endif
}

public final class BrazeApplicationService: BrazeApplicationServiceType {

    #if DEBUG || QA
    var forcedCards: [BrazeContentCard] = [] {
        didSet {
            refreshContentCards()
        }
    }
    #endif

    private var impressions = Set<String>()
    private var email: String?
    private(set) var client: Braze?
    private var authorizationObserver: NSObjectProtocol?
    private var authorizationRepository: AuthorizationRepositoryType?
    private var runningTask: Task<(), Never>?
    @Inject private var remoteConfigRepository: RemoteConfigRepositoryType
    @Inject private var monitor: Monitoring
    private let storage: Storage = resolve(tag: .default)
    private let configuration = Braze.Configuration(apiKey: AppConfiguration.shared.brazeAPIKey,
                                                    endpoint: AppConfiguration.shared.brazeEndpoint)

    static let maximumNumberOfDisplayedCards = 1
    static let supressCardsIntervalAfterDismissal = TimeInterval(8 * 60 * 60) // 8 hours

    init(authorizationRepository: AuthorizationRepositoryType = resolve()) {
        self.authorizationRepository = authorizationRepository
    }

    // MARK: - Initialize
    private func initialize() {
        guard remoteConfigRepository.brazeEnabled else { return }
        client = Braze(configuration: configuration)
        isEnabled = authorizationRepository?.authorization != nil
        registerNotifications()
    }

    // MARK: - ApplicationService Protocol
    func application(_ application: UIApplicationType,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initialize()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplicationType) {
        resetImpressionsOnForgrounding()
        refreshContentCards()
    }

    // MARK: - Private
    private func register(email: String) {
        self.email = email
        client?.user.set(email: email)
    }

    private func registerNotifications() {
        authorizationObserver = NotificationCenter.default
            .observe(for: AuthorizationDidChangeNotification.self,
                     object: nil,
                     queue: .main) { [weak self] notification in
                guard let self else { return }
                if notification.newValue == nil {
                    self.reset()
                } else {
                    isEnabled = true
                    self.refreshContentCards()
                }
            }
    }

    private func persistInitialRegistration() {
        guard remoteConfigRepository.brazeEnabled else { return }
        // Key is used as value as well since we just need any abritray value to be present in the store
        storage.store(StorageKey.brazeInitialIdentificationCompletedKey.description,
                      for: .brazeInitialIdentificationCompletedKey)
    }

    // MARK: Content Cards

    public func refreshContentCards() {
        guard remoteConfigRepository.contentCardsEnabled,
              let authorizationRepository,
              authorizationRepository.authorization != nil,
              runningTask == nil else { return }
        runningTask = Task { [weak self] in
            do {
                try await self?.refreshCards()
            } catch {
                self?.monitor.error(error, context: .crm)
            }
            self?.runningTask = nil
        }
    }

    private func refreshCards() async throws {
        guard let client,
              let cards = try? await client.contentCards.requestRefresh()
        else { return }

        if let mapped = try await mapRecievedCards(for: cards) {
            let notification = BrazeContentCardDidChangeNotification(allCards: mapped.all,
                                                                     displayedCards: mapped.display)
            NotificationCenter.default.post(notification, sender: self)
        }
    }

    private func mapRecievedCards(for cards: [Braze.ContentCard]) async throws -> (display: [BrazeContentCard], all: [BrazeContentCard])? {

        // The number of cards to be displayed is calculated as:
        // The maximum number that can be displayed, MINUS the
        // number of cards dismissed within the last 8 hours.
        // This means that when a user dismisses a content card,
        // a new one may take its place only after 8 hours.
        var numberOfCardsToDisplay = Self.maximumNumberOfDisplayedCards

        let previousContentCardDismissDates: [Date]? = storage.get(for: .lastContentCardDismissDates)

        if var previousContentCardDismissDates {
            // remove the dates of the cards that were dismissed more than 8h ago
            previousContentCardDismissDates.removeAll {
                $0.addingTimeInterval(Self.supressCardsIntervalAfterDismissal).isEarlier(than: Date())
            }
            // numberOfCardsToDisplay = maximumNumberOfDisplayedCards - (The number of cards that were dismissed within the last 8 hours)
            numberOfCardsToDisplay -= previousContentCardDismissDates.count

            // Safty check: number of cards to display can't be less than zero
            numberOfCardsToDisplay = max(0, numberOfCardsToDisplay)

            storage.store(previousContentCardDismissDates, for: .lastContentCardDismissDates)
        }

        let allCards = Self.preProcessCards(cards: cards)
        let displayedCards = Array(allCards.prefix(numberOfCardsToDisplay))

        let mappedAllCards = try await self.mapCards(allCards, loadImage: false)

        let mappedDisplayedCards = try await self.mapCards(displayedCards, loadImage: true)

        #if DEBUG || QA
        // If the user has pinned any cards for debugging, use them instead
        if !forcedCards.isEmpty {
            return (display: forcedCards, all: mappedAllCards)
        }
        #endif

        return (display: mappedDisplayedCards, all: mappedAllCards)

    }

    private func mapCards(_ cards: [Braze.ContentCard], loadImage: Bool) async throws -> [BrazeContentCard] {
        var mappedCards = [BrazeContentCard]()
        for card in cards {
            switch card {

            case .captionedImage(let captionedImage):
                var image: UIImage?
                if loadImage {
                    // If the image fails to download, fetchAssets() will throw
                    // and the card refresh will stop. Next time the app is
                    // forgrounded, it will be attempted again.
                   image = try await self.fetchAssets(for: captionedImage)
                }
                mappedCards.append(.captionedImage(captionedImage, image: image))
            case .classic(let classic):
                mappedCards.append(.classic(classic))
            default:
                // If we recieve a card with an unsupported type,
                // we log it as a warning and continue
                let error = BrazeError.unsupportedContentCardType(card)
                card.context?.logError(error)
                monitor.warning(error, context: .crm)
            }
        }
        return mappedCards
    }

    private static func preProcessCards(cards: [Braze.ContentCard]) -> [Braze.ContentCard] {
        let filterdCards = cards.filter { $0.canBeDisplayed }
        let sortedCards = filterdCards.sorted {
            // The latest pinned cards are on top,
            // if no cards are pinned then
            // it's the latest non pinned cards on top
            if $0.pinned && $1.pinned {
                return $0.createdAt > $1.createdAt
            } else if $0.pinned {
                return true
            } else if $1.pinned {
                return false
            } else {
                return $0.createdAt > $1.createdAt
            }
        }
        return sortedCards
    }

    private func fetchAssets(for card: Braze.ContentCard.CaptionedImage) async throws -> UIImage? {
        do {
            let data = try await URLSession.shared.data(from: card.image).0
            if let image = UIImage(data: data) {
                return image
            } else {
                let error = BrazeError.invalidContnetCardImageData(card.image)
                card.context?.logError(error)
                throw error
            }
        } catch {
            let errorToThrow = BrazeError.failedToDownloadContentCardImage(card.image, error)
            card.context?.logError(errorToThrow)
            throw errorToThrow
        }
    }

    func conditionallyLogImpression(for card: BrazeContentCard) {

        // If impression was not tracked before
        if !impressions.contains(card.id) {
            switch card {
            case .captionedImage(let card, _):
                card.context?.logImpression()
            case .classic(let card):
                card.context?.logImpression()
            }

            impressions.insert(card.id)
        }
    }

    func storeDismissalDate() {
        // Store card dismissal date
        let lastContentCardDismissDates: [Date]? = storage.get(for: .lastContentCardDismissDates)
        var dates = lastContentCardDismissDates ?? []
        dates.append(Date())
        storage.store(dates, for: .lastContentCardDismissDates)
    }

    private func resetImpressionsOnForgrounding() {
        self.impressions = Set<String>()
    }

    // MARK: - Public

    func identify(id: String, email: String) {

        #if DEBUG || QA
        // WORKAROROUND:
        // We are creating a Braze account via our QA/DEBUG app inside Braze's "development" environment and identify users via "xid"
        // This "xid" is taken from the production database though since our QA/DEBUG app runs against production
        // This is a problem because:
        // Braze's "development" environment is also used via "staging web" and "qa web" for testing and running UI tests
        // Usually plenty of accounts are created during this process.
        // Both "staging" and "qa" are running on db snapshots that are created once a day or every 4 hours
        // User xid's are created based on a simple int which is incremented for each new user -> xid's are simly obfuscared INTs
        // This becomes a problem here during QA if the user number  we create on production has already been created with the same
        // INT via "staging web" or "qa web". They will have the same xid and the user data in Braze will be ambiguous
        // Just adding a prefix here will solve this well enough for our reasons. Since the data will ony go to a dev
        // environment, this will not have any effect on production.
        // Just running the QA app against the staging backend or QA backend is not an options because:
        // * Out Apollo networking code is especially created for production on build time
        // * We would potentially still get xid collisions because the qa/stagings databses are messed aroudn a lot with
        let id = "iOSPrefixToAvoidXIDCollisions-\(id)"
        #else
        let id = id
        #endif

        client?.changeUser(userId: id)
        register(email: email)
        persistInitialRegistration()
    }
    public func reset() {
        #if DEBUG || QA
        forcedCards = []
        #endif
        client?.wipeData()
        isEnabled = false
        email = nil
        storage.store(nil as [Date]?, for: .lastContentCardDismissDates)
        storage.store(nil as String?, for: .brazeInitialIdentificationCompletedKey)
    }

    public var isEnabled: Bool {
        get { client?.enabled ?? false }
        set { client?.enabled = newValue }
    }

    // Should be called for pre-braze-app-version users who are logged in. They should register first time they
    // get to the dashboard.
    public var isLoginTrackingNeeded: Bool {
        guard remoteConfigRepository.brazeEnabled else { return false }
        let returnValue: String? = storage.get(for: .brazeInitialIdentificationCompletedKey)
        return returnValue == nil
    }
}
