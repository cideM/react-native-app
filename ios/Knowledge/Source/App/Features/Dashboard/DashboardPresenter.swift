//
//  DashboardPresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 16.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit
import Domain
import Localization
import DesignSystem
import BrazeKit

protocol DashboardPresenterType: AnyObject {
    var view: DashboardViewType? { get set }
    func didTapSearch()
    func didTapAllRecentsButton()
    func didTapIAPBanner()
    func didTapStageButton()
    func didTapLinkButton(url: URL, completion: @escaping () -> Void)
    func refreshUserStageButton()
    func didTapContentCard(at index: Int)
    func didDismissContentCard(at index: Int)
    func didViewContentCard(at index: Int)
    func shouldOpenContentCardFeed()
    func viewWillAppear()
    func viewWillDisappear()
}

final class DashboardPresenter: DashboardPresenterType {
    weak var view: DashboardViewType? {
        didSet {
            updateSections()

            showIAPBannerIfNeeded(with: inAppPurchaseApplicationService.purchaseInfo())
            inAppPurchaseApplicationService.updateStoreState()

            refreshUserStageButton()
            userStageObserver = NotificationCenter.default.observe(for: UserStageDidChangeNotification.self, object: userDataRepository, queue: .main) { [weak self] _ in
                self?.refreshUserStageButton()
                self?.updateSections()
            }
        }
    }

    private let coordinator: DashboardCoordinatorType
    private let trackingProvider: TrackingType
    private let tagRepository: TagRepositoryType
    private let libraryRepository: LibraryRepositoryType
    private let brazeService: BrazeApplicationServiceType
    private let eventTracking: TrackingType
    private let maxNumberOfRecents: Int
    private let appConfiguration: Configuration
    private let storage: Storage
    private let remoteConfigRepository: RemoteConfigRepositoryType
    private let featureFlagRepository: FeatureFlagRepositoryType
    private let consentApplicationService: ConsentApplicationServiceType
    private let inAppPurchaseApplicationService: InAppPurchaseApplicationServiceType
    private var userDataRepository: UserDataRepositoryType
    private var userStageObserver: NSObjectProtocol?
    private let listTrackingProvider: ListTrackingProvider
    private var tagObserver: NSObjectProtocol?
    private var purchaseEntitlementsObserver: NSObjectProtocol?
    private var contentCardsObserver: NSObjectProtocol?
    private var authorizationRepository: AuthorizationRepositoryType

    private var sections: [DashboardSection] = []
    private var contentCards: [BrazeContentCard] = []
    private var allContentCards: [BrazeContentCard] = []
    private var contentCardImpressions: [Bool] = []
    private var isViewVisible = false
    private var shouldUpdateWhenVisible = true

    private static let pocketGuidesFeatureFlag = "can_see_pocket_guides"

    init(coordinator: DashboardCoordinatorType,
         trackingProvider: TrackingType = resolve(),
         appConfiguration: Configuration = AppConfiguration.shared,
         tagRepository: TagRepositoryType = resolve(),
         libraryRepository: LibraryRepositoryType = resolve(),
         maxNumberOfRecents: Int,
         storage: Storage = resolve(tag: .default),
         remoteConfigRepository: RemoteConfigRepositoryType = resolve(),
         featureFlagRepository: FeatureFlagRepositoryType = resolve(),
         consentApplicationService: ConsentApplicationServiceType = resolve(),
         inAppPurchaseApplicationService: InAppPurchaseApplicationServiceType = resolve(),
         userDataRepository: UserDataRepositoryType = resolve(),
         listTrackingProvider: ListTrackingProvider,
         brazeClient: BrazeApplicationServiceType = resolve(),
         eventTracking: TrackingType = resolve(),
         authorizationRepository: AuthorizationRepositoryType = resolve()) {

        self.coordinator = coordinator
        self.trackingProvider = trackingProvider
        self.tagRepository = tagRepository
        self.libraryRepository = libraryRepository
        self.maxNumberOfRecents = maxNumberOfRecents
        self.appConfiguration = appConfiguration
        self.storage = storage
        self.remoteConfigRepository = remoteConfigRepository
        self.featureFlagRepository = featureFlagRepository
        self.consentApplicationService = consentApplicationService
        self.inAppPurchaseApplicationService = inAppPurchaseApplicationService
        self.userDataRepository = userDataRepository
        self.listTrackingProvider = listTrackingProvider
        self.brazeService = brazeClient
        self.eventTracking = eventTracking
        self.authorizationRepository = authorizationRepository

        self.tagObserver = NotificationCenter.default.observe(for: TaggingsDidChangeNotification.self, object: tagRepository, queue: .main) { [weak self] _ in

            self?.updateSections()
        }

        self.contentCardsObserver = NotificationCenter.default.observe(for: BrazeContentCardDidChangeNotification.self, object: nil, queue: .main, using: { [weak self] notification in
            guard let self else { return }
            self.allContentCards = notification.allCards
            self.contentCards = notification.displayedCards
            self.contentCardImpressions = Array(repeating: false, count: notification.displayedCards.count)
            self.shouldUpdateWhenVisible = true
        })
    }

    func updateSections() {
        guard isViewVisible else {
            self.shouldUpdateWhenVisible = true
            return
        }

        self.shouldUpdateWhenVisible = false
        sections = []

        sections.append(.clinicalTools(clinicalToolsViewData()))

        if
            appConfiguration.appVariant == .wissen,
            userDataRepository.userStage == .physician,
            remoteConfigRepository.dashboardCMELinkEnabled {
            sections.append(.externalLink(
                externalLinkViewData(
                    title: L10n.Dashboard.Section.Cme.title,
                    text: L10n.Dashboard.Section.Cme.text,
                    url: appConfiguration.cmeURL,
                    image: Asset.cmeStamp.image
                )))
        }

        if !contentCards.isEmpty {
            sections.append(.highlights(highlightsViewData(cards: contentCards)))
            // BRAZE LOGIC: We agreed to record a card impression when the dashboard becomes visible
            for index in 0..<contentCards.count {
                self.didViewContentCard(at: index)
            }
        }

        sections.append(.recents(recentsViewData()))

        view?.setSections(sections: sections)
    }

    func viewWillAppear() {
        isViewVisible = true
        if shouldUpdateWhenVisible {
            updateSections()
        }
    }

    func viewWillDisappear() {
        isViewVisible = false
        brazeService.refreshContentCards()
    }

    func didTapSearch() {
        coordinator.navigate(to: .search(nil))
    }

    func didTapStageButton() {
        coordinator.navigateToUserStageSettings()
    }

    func didTapLinkButton(url: URL, completion: @escaping () -> Void) {
        coordinator.showAppToWebURL(url, completion: completion)

        if url == appConfiguration.cmeURL {
            trackingProvider.track(.dashboardCMECardClicked)
        }
    }

    func didTapAllRecentsButton() {
        coordinator.navigateToCompleteRecentsList()
    }

    func didTapIAPBanner() {
        coordinator.navigateToStore()
    }

    func didTapContentCard(at index: Int) {
        guard let card = contentCards[safe: index], let url = contentCards[safe: index]?.url else { return }
        card.context?.logClick()
        let deeplink = Deeplink(url: url)

        if case .unsupported(let url) = deeplink {
            // open in inAppBrowser
            coordinator.showUrl(url: url)
        } else {
            // open correct deeplink
            coordinator.navigate(to: deeplink)
        }
    }

    func didDismissContentCard(at index: Int) {
        guard let card = contentCards[safe: index] else { return }
        card.context?.logDismissed()
        brazeService.storeDismissalDate()
        contentCards.remove(at: index)

        updateSections()
    }

    func didViewContentCard(at index: Int) {
        guard let card = contentCards[safe: index] else { return }
        brazeService.conditionallyLogImpression(for: card)
    }

    func shouldOpenContentCardFeed() {
        coordinator.navigateToContentCardFeed(cards: allContentCards)
    }

    private func didTap(clinicalTool: ClinicalTool) {
        coordinator.navigateToContentList(for: clinicalTool)

        let contentType = getCCLEContentType(from: clinicalTool)
        trackingProvider.track(.ccleDashboardButtonClicked(contentType: contentType))
    }

    func refreshUserStageButton() {
        guard let stage = userDataRepository.userStage else { return }
        let title = UserStageViewData.Item(stage).shortTitle
        view?.updateStageButton(with: title.uppercased())
    }

    private func showIAPBannerIfNeeded(with info: InAppPurchaseInfo) {
        let userShouldSeeOffer = !info.hasActiveIAPSubscription && info.hasTrialAccess && info.canPurchase
        let isTrialRemoved = remoteConfigRepository.iap5DayTrialRemoved
        let title = isTrialRemoved ? L10n.Dashboard.IapBanner.titleVariant : L10n.Dashboard.IapBanner.title
        let subtitle = isTrialRemoved ? L10n.Dashboard.IapBanner.subTitleVariant : L10n.Dashboard.IapBanner.subTitle

        view?.updateIAPBanner(title: title, subtitle: subtitle, isHidden: !userShouldSeeOffer)

        purchaseEntitlementsObserver = NotificationCenter.default.observe(for: InAppPurchaseInfoDidChangeNotification.self, object: inAppPurchaseApplicationService, queue: .main) { [weak self] change in
            let info = change.newValue
            self?.showIAPBannerIfNeeded(with: info)
        }
    }

    private func clinicalToolsViewData() -> DashboardSectionViewData {
        var clinicalTools = [
            ClinicalTool.drugDatabase,
            ClinicalTool.flowcharts,
            ClinicalTool.calculators,
            ClinicalTool.guidelines
        ]

        if  self.featureFlagRepository.featureFlags.contains(Self.pocketGuidesFeatureFlag) {
            clinicalTools.insert(.pocketGuides, at: 0)
            coordinator.preloadPocketGuides()
        }

        let items: [DashboardSectionViewData.Item] = clinicalTools.map { item in

            let clinicalToolItem = DashboardSectionViewData.ClinicalToolDashboardItem(clinicalTool: item) { [weak self] item in
                self?.didTap(clinicalTool: item)
            }
            return DashboardSectionViewData.Item.clinicalTool(clinicalToolItem)
        }

        return DashboardSectionViewData(title: L10n.Dashboard.Sections.ClinicalTools.title,
                                        items: items,
                                        showsHeader: true,
                                        hasSeparator: false,
                                        canHaveAllButton: false,
                                        tapAllClosure: nil)
    }

    private func highlightsViewData(cards: [BrazeContentCard]) -> DashboardSectionViewData {
        let items: [DashboardSectionViewData.Item] = cards.enumerated().map { index, card in
            switch card {
            case .captionedImage(let card, let image):
                return DashboardSectionViewData.Item.contentCard(
                    ContentCardView.ViewData(index: index,
                                             image: image,
                                             imageURL: card.image,
                                             title: card.title,
                                             subtitle: card.description,
                                             action: card.domain,
                                             isDismisable: card.dismissible,
                                             isClickable: card.clickAction != nil,
                                             isSelected: false,
                                             insets: .zero))
            case .classic(let card):
                return DashboardSectionViewData.Item.contentCard(
                    ContentCardView.ViewData(index: index,
                                             image: nil,
                                             imageURL: nil,
                                             title: card.title,
                                             subtitle: card.description,
                                             action: card.domain,
                                             isDismisable: card.dismissible,
                                             isClickable: card.clickAction != nil,
                                             isSelected: false,
                                             insets: .zero))
            }
        }

        return DashboardSectionViewData(title: nil,
                                        items: items,
                                        showsHeader: false,
                                        hasSeparator: true,
                                        canHaveAllButton: false,
                                        tapAllClosure: nil)
    }

    private func externalLinkViewData(title: String, text: String, url: URL, image: UIImage?) -> DashboardSectionViewData {
        DashboardSectionViewData(
            title: title,
            items: [
                .externalLink(text: text, url: url, image: image)
            ],
            showsHeader: true,
            hasSeparator: false,
            canHaveAllButton: false,
            tapAllClosure: nil)
    }

    private func recentsViewData() -> DashboardSectionViewData {
        let recents = tagRepository.learningCardsSortedByDate(with: .opened)
            .prefix(maxNumberOfRecents)
            .compactMap { try? libraryRepository.library.learningCardMetaItem(for: $0) }

        let tapAllClosure: () -> Void = { [weak self] in
            self?.didTapAllRecentsButton()
        }

        let items: [DashboardSectionViewData.Item]

        if recents.isEmpty {
            items = [DashboardSectionViewData.Item.text(L10n.Lists.Recents.EmptyState.text)]
        } else {
            let recentItems = recents.map { metaData in
                DashboardSectionViewData.ArticleDashboardItem(
                    learningCardMetaItem: metaData,
                    isFavorite: tagRepository.hasTag(.favorite, for: metaData.learningCardIdentifier),
                    isLearned: tagRepository.hasTag(.learned, for: metaData.learningCardIdentifier)) { [weak self] learningCardMetaItem in

                        self?.didSelectArticleItem(learningCardMetaItem)
                }
            }
            items = recentItems.map { DashboardSectionViewData.Item.article($0) }
        }

        return DashboardSectionViewData(title: L10n.Dashboard.Sections.RecentlyRead.title,
                                        items: items,
                                        showsHeader: true,
                                        hasSeparator: false,
                                        canHaveAllButton: true,
                                        tapAllClosure: tapAllClosure)
    }

    private func didSelectArticleItem(_ item: LearningCardMetaItem) {
        coordinator.navigate(to: Deeplink.learningCard(LearningCardDeeplink(learningCard: item.learningCardIdentifier, anchor: nil, particle: nil, sourceAnchor: nil)))
        listTrackingProvider.track(learningCard: item.learningCardIdentifier, tag: .opened)
    }

    private func getCCLEContentType(from clinicalTool: ClinicalTool) -> Tracker.Event.Dashboard.CCLEContentType {
        switch clinicalTool {
        case .pocketGuides: return .pocketGuide
        case .drugDatabase:
            switch appConfiguration.appVariant {
            case .knowledge: return .monograph
            case .wissen: return .pharmaCard
            }
        case .flowcharts: return .flowchart
        case .calculators: return .calculator
        case .guidelines: return .guidline
        }
    }
}
