//
//  LearningCardPresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 10.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Networking
import UIKit
import Localization

final class LearningCardPresenter: LearningCardPresenterType {

    weak var view: LearningCardViewType? {
        didSet {
            if let deeplink = learningCardStack.currentItem {
                loadLearningCard(deeplink)
            }
            updateToolbar()
        }
    }

    private let learningCardStack: PointableStack<LearningCardDeeplink>
    private var isLearningCardHtmlRendered = false

    private let coordinator: LearningCardCoordinatorType
    private let libraryRepository: LibraryRepositoryType
    private let learningCardOptionsRepository: LearningCardOptionsRepositoryType
    private let userDataRepository: UserDataRepositoryType
    private let tagRepository: TagRepositoryType
    private let extensionRepository: ExtensionRepositoryType
    private let learningCardShareRepository: LearningCardShareRepostitoryType
    private let authorizationRepository: AuthorizationRepositoryType
    private let sharedExtensionRepository: SharedExtensionRepositoryType
    private let deviceSettingsRepository: DeviceSettingsRepositoryType
    private let accessRepository: AccessRepositoryType
    private let galleryRepository: GalleryRepositoryType
    private let qbankAnswerRepository: QBankAnswerRepositoryType
    private let snippetRepository: SnippetRepositoryType
    private let remoteConfigRepository: RemoteConfigRepositoryType
    private var tracker: LearningCardTracker
    private let readingRepository: ReadingRepositoryType
    private let userDataClient: UserDataClient
    private let appConfiguration: Configuration
    private let htmlSizeCalculationService: HTMLContentSizeCalculatorType
    private let inAppPurchaseApplicationService: InAppPurchaseApplicationServiceType
    private let configuration: Configuration

    private var userStageDidChangeObserver: NSObjectProtocol?
    private var highlightingModeDidChangeObserver: NSObjectProtocol?
    private var highYieldModeDidChangeObserver: NSObjectProtocol?
    private var physikumFokusModeDidChangeObserver: NSObjectProtocol?
    private var learningRadarModeDidChangeObserver: NSObjectProtocol?
    private var taggingsDidChangeObserver: NSObjectProtocol?
    private var extensionsDidChangeObserver: NSObjectProtocol?
    private var sharedExtensionsDidChangeObserver: NSObjectProtocol?
    private var fontSizeDidChangeObserver: NSObjectProtocol?
    private var applicationDidBecomeActiveObserver: NSObjectProtocol?
    private var applicationWillResignActiveObserver: NSObjectProtocol?
    private var healthCareProfessionObserver: NSObjectProtocol?

    private var openSectionCount = 0 {
        didSet {
            view?.canOpenAllSections = openSectionCount == 0
        }
    }

    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
        endReading()
    }

    init(coordinator: LearningCardCoordinatorType,
         libraryRepository: LibraryRepositoryType = resolve(),
         learningCardStack: PointableStack<LearningCardDeeplink>,
         learningCardOptionsRepository: LearningCardOptionsRepositoryType,
         userDataRepository: UserDataRepositoryType,
         tagRepository: TagRepositoryType,
         extensionRepository: ExtensionRepositoryType = resolve(),
         learningCardShareRepository: LearningCardShareRepostitoryType,
         authorizationRepository: AuthorizationRepositoryType = resolve(),
         sharedExtensionRepository: SharedExtensionRepositoryType = resolve(),
         deviceSettingsRepository: DeviceSettingsRepositoryType = resolve(),
         accessRepository: AccessRepositoryType = resolve(),
         galleryRepository: GalleryRepositoryType,
         snippetRepository: SnippetRepositoryType,
         remoteConfigRepository: RemoteConfigRepositoryType = resolve(),
         qbankAnswerRepository: QBankAnswerRepositoryType = resolve(),
         trackingProvider: TrackingType = resolve(),
         readingRepository: ReadingRepositoryType = resolve(),
         userDataClient: UserDataClient = resolve(),
         appConfiguration: Configuration = AppConfiguration.shared,
         htmlSizeCalculationService: HTMLContentSizeCalculatorType = resolve(),
         inAppPurchaseApplicationService: InAppPurchaseApplicationServiceType = resolve(),
         configuration: Configuration = AppConfiguration.shared,
         tracker: LearningCardTracker
    ) {
        self.coordinator = coordinator
        self.libraryRepository = libraryRepository
        self.learningCardStack = learningCardStack
        self.learningCardOptionsRepository = learningCardOptionsRepository
        self.userDataRepository = userDataRepository
        self.tagRepository = tagRepository
        self.extensionRepository = extensionRepository
        self.learningCardShareRepository = learningCardShareRepository
        self.authorizationRepository = authorizationRepository
        self.sharedExtensionRepository = sharedExtensionRepository
        self.deviceSettingsRepository = deviceSettingsRepository
        self.accessRepository = accessRepository
        self.galleryRepository = galleryRepository
        self.qbankAnswerRepository = qbankAnswerRepository
        self.snippetRepository = snippetRepository
        self.remoteConfigRepository = remoteConfigRepository
        self.readingRepository = readingRepository
        self.userDataClient = userDataClient
        self.appConfiguration = appConfiguration
        self.htmlSizeCalculationService = htmlSizeCalculationService
        self.inAppPurchaseApplicationService = inAppPurchaseApplicationService
        self.configuration = configuration
        self.tracker = tracker

        UIApplication.shared.isIdleTimerDisabled = deviceSettingsRepository.keepScreenOn

        resetHiddenToggles(for: userDataRepository.userStage)

        userStageDidChangeObserver = NotificationCenter.default.observe(for: UserStageDidChangeNotification.self, object: userDataRepository, queue: .main, using: { [weak self] change in
            self?.view?.setPhysicianModeIsOn(change.newValue == .physician)
        })

        highlightingModeDidChangeObserver = NotificationCenter.default.observe(for: HighlightingModeDidChangeNotification.self, object: learningCardOptionsRepository, queue: .main) { [weak self] change in
            let isEnabled = change.newValue
            self?.view?.changeHighlightingMode(isEnabled)
            self?.tracker.trackHighlighting(isEnabled: isEnabled)
        }

        healthCareProfessionObserver = NotificationCenter.default.observe(for: ProfessionConfirmationDidChangeNotification.self, object: userDataRepository, queue: .main) { [weak self] change in
            change.newValue ? self?.view?.revealTrademarks() : self?.view?.hideTrademarks()
        }

        highYieldModeDidChangeObserver = NotificationCenter.default.observe(for: HighYieldModeDidChangeNotification.self, object: learningCardOptionsRepository, queue: .main) { [weak self] change in
            let isEnabled = change.newValue
            self?.view?.changeHighYieldMode(isEnabled)
            self?.tracker.trackHighYield(isEnabled: isEnabled)
        }

        physikumFokusModeDidChangeObserver = NotificationCenter.default.observe(for: PhysikumFokusModeDidChangeNotification.self, object: learningCardOptionsRepository, queue: .main) { [weak self] change in
            self?.view?.changePhysikumFokusMode(change.newValue)
        }

        learningRadarModeDidChangeObserver = NotificationCenter.default.observe(for: LearningRadarDidChangeNotification.self, object: learningCardOptionsRepository, queue: .main) { [weak self] change in
            let isEnabled = change.newValue
            self?.view?.changeLearningRadarMode(isEnabled)
            self?.tracker.trackLearningRadar(isEnabled: isEnabled)
        }

        taggingsDidChangeObserver = NotificationCenter.default.observe(for: TaggingsDidChangeNotification.self, object: tagRepository, queue: .main) { [weak self] _ in
            if let deeplink = learningCardStack.currentItem {
                self?.view?.isFavorite = tagRepository.hasTag(.favorite, for: deeplink.learningCard)
            }
        }

        extensionsDidChangeObserver = NotificationCenter.default.observe(for: ExtensionsDidChangeNotification.self, object: extensionRepository, queue: .main) { [weak self] _ in
            guard let learningCardIdentifier = learningCardStack.currentItem?.learningCard else { return }
            self?.setExtensions(for: learningCardIdentifier)
        }

        sharedExtensionsDidChangeObserver = NotificationCenter.default.observe(for: SharedExtensionsDidChangeNotification.self, object: sharedExtensionRepository, queue: .main) { [weak self] _ in
            guard let learningCardIdentifier = learningCardStack.currentItem?.learningCard else { return }
            self?.setSharedExtensions(for: learningCardIdentifier)
        }

        fontSizeDidChangeObserver = NotificationCenter.default.observe(for: FontSizeDidChangeNotification.self, object: deviceSettingsRepository, queue: .main) { [weak self] change in
            guard let self = self, let fontScale = change.newValue else { return }
            self.view?.setFontSize(size: self.calculateFontSize(fontScale))
        }

        applicationDidBecomeActiveObserver = NotificationCenter.default.observe(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            if let learningCard = learningCardStack.currentItem?.learningCard {
                self?.startReading(for: learningCard)
                self?.tracker.trackStartReading(for: learningCard)
            }
        }

        applicationWillResignActiveObserver = NotificationCenter.default.observe(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.endReading()
        }

    }

    /// Turns off all hidden switches behind the scenes
    private func resetHiddenToggles(for stage: UserStage?) {
        guard let stage = stage else { return }

        switch stage {
        case .clinic:
            learningCardOptionsRepository.isPhysikumFokusModeOn = false
        case .physician:
            learningCardOptionsRepository.isPhysikumFokusModeOn = false
            learningCardOptionsRepository.isHighlightingModeOn = false
            learningCardOptionsRepository.isLearningRadarOn = false
            learningCardOptionsRepository.isHighYieldModeOn = false
        case .preclinic: break
        }
    }

    func go(to learningCardDeeplink: LearningCardDeeplink) {
        load(learningCardDeeplink)
        addDeepLinktoStack(learningCardDeeplink)
        updateToolbar()
    }

    private func addDeepLinktoStack(_ newItem: LearningCardDeeplink) {
        let currentItem = learningCardStack.currentItem
        if currentItem?.learningCard != newItem.learningCard ||
            currentItem?.anchor != newItem.anchor ||
            currentItem?.particle != newItem.particle {
            // If the top article in the stack has a different learningCardId or anchorId or particleId
            // -> we append the newItem to the stack
            learningCardStack.append(newItem)
        }
    }

    func goToPreviousLearningCard() {
        guard let sourceDeeplink = learningCardStack.currentItem,
            let destinationDeeplink = learningCardStack.previousItem else {
                return assertionFailure("Couldn't go to the previous learning card")
        }
        load(LearningCardDeeplink(learningCard: destinationDeeplink.learningCard, anchor: sourceDeeplink.sourceAnchor, particle: sourceDeeplink.particle, sourceAnchor: nil))
        learningCardStack.decreasePointer()
        updateToolbar()
        tracker.trackNavigatedBackward()
    }

    func goToNextLearningCard() {
        guard let destinationDeeplink = learningCardStack.nextItem else {
            return assertionFailure("Couldn't go to the next learning card")
        }
        load(destinationDeeplink)
        learningCardStack.increasePointer()
        updateToolbar()
        tracker.trackNavigatedForward()
    }

    private func configureNavigationControls() {
        view?.canNavigateToNext = learningCardStack.isPointerIncreasable
        view?.canNavigateToPrevious = learningCardStack.isPointerDecreasable
    }

    func closeLearningCardOverlay() {
        coordinator.stop(animated: true)
    }

    /// This method is responsible for loading a learning card using its deep link.
    /// If this is the same learning card we're on, it will only scroll to the specified section.
    /// If this is a new learning card it will try to load and render the HTML content of that learning card using `loadLearningCard(learningcard:anchor:)` method.
    /// - Parameter deeplink: The learning card deep link to load.
    private func load(_ deeplink: LearningCardDeeplink) {
        let isSameLearningCard = deeplink.learningCard == learningCardStack.currentItem?.learningCard
        if isSameLearningCard {
            goToSection(deeplink)
        } else {
            loadLearningCard(deeplink)
        }
    }

    private func goToSection(_ deeplink: LearningCardDeeplink) {
        if let anchor = deeplink.anchor {
            if view?.canGoTo(anchor: anchor) ?? false {
                view?.go(to: anchor, question: deeplink.question)
                return
            } else {
                tracker.trackArticleAnchorIdInvalid(articleID: deeplink.learningCard.value,
                                                    id: anchor.value)
            }
        }

        if let particle = deeplink.particle {
            if view?.canGoTo(anchor: particle) ?? false {
                view?.go(to: particle, question: deeplink.question)
                return
            } else {
                tracker.trackArticleParticleIdInvalid(articleID: deeplink.learningCard.value,
                                                           id: particle.value)
            }
        }
    }

    /// This method is responsible for loading and rendering the HTML content of a learning card using its identifier and an optional anchor.
    /// This method is the one to use for retries for example, when we want to try to reload the current learning card.
    /// - Parameters:
    ///   - deeplink: The deeplink of the learning card to load.
    private func loadLearningCard(_ deeplink: LearningCardDeeplink) {
        guard let view = view else { return }
        view.setIsLoading(true)

        /// When navigating from a learning card to another the previous learning card reading should be ended.
        if let currentItem = learningCardStack.currentItem?.learningCard, currentItem != deeplink.learningCard {
            let reading = readingRepository.endReading(for: currentItem)
            tracker.trackEndReading(for: currentItem, with: reading)
            isLearningCardHtmlRendered = false
        }

        guard let learningCardMetaItem = try? libraryRepository.library.learningCardMetaItem(for: deeplink.learningCard) else {
            let message = PresentableMessage(title: L10n.Error.Generic.title,
                                             description: L10n.LearningCard.Error.LearningCardMetadataNotFound.message,
                                             logLevel: .info)
            view.presentLearningCardError(message, [MessageAction.dismiss])
            return
        }

        // iOS_PAYWALL_EXPERIMENT
        // Present paywall regardless of whether the user has a trial access or not.
        // Present the paywall if there is NO active subscription and the user can purchase one
        if remoteConfigRepository.iap5DayTrialRemoved {
            let info = self.inAppPurchaseApplicationService.purchaseInfo()
            if !info.hasActiveIAPSubscription &&
                info.canPurchase &&
                !learningCardMetaItem.alwaysFree {
                self.presentPaywall(for: AccessError.accessRequired, deeplink: deeplink)
                return
            }
        }

        accessRepository.getAccess(for: learningCardMetaItem) { [weak self, deeplink] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.tagRepository.addTag(.opened, for: deeplink.learningCard)

                let learningCardMetaItem = try? self.libraryRepository.library.learningCardMetaItem(for: deeplink.learningCard)
                self.view?.setTitle(learningCardMetaItem?.title ?? "")

                self.view?.load(learningCard: deeplink.learningCard) {
                    self.goToSection(deeplink)
                }

            case .failure(let accessError):
                self.presentPaywall(for: accessError, deeplink: deeplink)
            }
        }
    }

    private func imageTapped(galleryIdentifier: GalleryIdentifier, imageOffset: Int) {
        let galleryDeeplink = GalleryDeeplink(gallery: galleryIdentifier, imageOffset: imageOffset)
        if let externalAddition = galleryRepository.primaryExternalAddition(for: galleryDeeplink) {
            coordinator.navigate(to: externalAddition.identifier, tracker: tracker)
        } else {
            coordinator.showImageGallery(galleryDeeplink, tracker: tracker)
        }
    }

    func closeAllSections() {
        view?.closeAllSections()
        tracker.trackCloseAllSections()
    }

    func openAllSections() {
        view?.openAllSections()
        tracker.trackOpenAllSections()
    }

    func toggleIsFavorite() {
        guard let view = view else { return }

        if let currentItem = learningCardStack.currentItem {
            let isFavorite = !view.isFavorite
            if isFavorite {
                tagRepository.addTag(.favorite, for: currentItem.learningCard)
            } else {
                tagRepository.removeTag(.favorite, for: currentItem.learningCard)
            }
            tracker.trackArticleFavorite(isFavorite: isFavorite)
        }
    }

    private func activateStudyObjective() {
        // Study objectives are currently only suppoerted for US learning cards
        // To avoid any potential conflicts this is generally ignored for DE
        switch configuration.appVariant {
        case .knowledge:
            guard let studyObjectiveSuperSet = userDataRepository.studyObjective?.superset else { return }
            view?.activateStudyObjective(studyObjectiveSuperSet)
        case .wissen:
            return
        }
    }

    private func injectWrongAnsweredQuestions() {
        guard
            let currentLearningCardIdentifier = learningCardStack.currentItem?.learningCard,
            let currentLearningCardMetaItem = try? libraryRepository.library.learningCardMetaItem(for: currentLearningCardIdentifier)
        else { return }
        view?.setWrongAnsweredQuestions(questionIDs: qbankAnswerRepository.wronglyAnsweredQuestions(for: currentLearningCardMetaItem.questions))
    }

    private func setExtensions(for learningCard: LearningCardIdentifier) {
        self.view?.setExtensions(extensionRepository.extensions(for: learningCard))
    }

    private func setSharedExtensions(for learningCard: LearningCardIdentifier) {
        self.view?.setSharedExtensions(sharedExtensionRepository.sharedExtensions(for: learningCard))
    }

    func showInArticleSearch() {
        view?.showInArticleSearchView()
        tracker.trackInArticleSearchOpened()
    }

    func showLearningCardOptions() {
        coordinator.showLearningCardOptions(tracker: self.tracker)
        tracker.trackOptionsMenuOpened()
    }

    func openURL(_ url: URL) {
        coordinator.openURLExternally(url)
    }

    func showMiniMap() {
        view?.getLearningCardModes { [learningCardStack, weak coordinator] result in
            guard case let .success(modes) = result, let learningCard = learningCardStack.currentItem?.learningCard else { return }
            coordinator?.showMiniMap(for: learningCard, with: modes)
        }
    }

    func shareLearningCard() {
        guard
            let learningCardIdentifier = learningCardStack.currentItem?.learningCard,
            let learningCardMetaItem = try? libraryRepository.library.learningCardMetaItem(for: learningCardIdentifier)
        else { return }

        let userName = authorizationRepository.authorization?.user.firstName ?? ""
        let shareLearningCardItem = learningCardShareRepository.learningCardShareItem(for: learningCardMetaItem, with: userName)
        tracker.trackPresentShareSheet()
        coordinator.share(shareLearningCardItem) { [weak self] didShare in
            if didShare { self?.tracker.trackShareSent() }
        }
    }

    private func presentPaywall(for accessError: AccessError,
                                deeplink: LearningCardDeeplink) {

        func tryAgainAction(style: MessageAction.Style = .normal) -> MessageAction {
            MessageAction(title: L10n.Generic.retry, style: style) { [weak self] in
                self?.loadLearningCard(deeplink)
                return true
            }
        }

        func buyLicenseAction(style: MessageAction.Style = .primary) -> MessageAction {
            MessageAction(title: L10n.InAppPurchase.Paywall.buyLicense, style: style) { [weak coordinator] in
                coordinator?.goToStore(dismissModally: false, animated: true)
                return false
                // "false" because the error overlay should stay in place
                // Loading of the content failed, so there is none and hence nothing to see under the error screen
            }
        }

        let messageTitle: String
        let messageDescription: String
        let messageActions: [MessageAction]

        switch accessError {
        case .offlineAccessExpired:
            messageTitle = L10n.InAppPurchase.Paywall.OfflineAccessExpired.title
            messageDescription = L10n.InAppPurchase.Paywall.OfflineAccessExpired.message
            messageActions = [buyLicenseAction(), tryAgainAction()]
        case .campusLicenseUserAccessExpired:
            messageTitle = L10n.InAppPurchase.Paywall.CampusLicenseExpired.title
            messageDescription = L10n.InAppPurchase.Paywall.CampusLicenseExpired.message
            messageActions = [buyLicenseAction(), tryAgainAction()]
        case .accessRequired, .accessConsumed, .accessExpired:
            messageTitle = L10n.InAppPurchase.Paywall.AccessRequired.title
            messageDescription = L10n.InAppPurchase.Paywall.AccessRequired.message
            messageActions = [buyLicenseAction(), tryAgainAction()]
        case .unknown:
            messageTitle = L10n.InAppPurchase.Paywall.UnknownAccessError.title
            messageDescription = L10n.InAppPurchase.Paywall.UnknownAccessError.message
            messageActions = [tryAgainAction(style: .primary), buyLicenseAction(style: .normal)]
        }

        view?.presentLearningCardError(PresentableMessage(title: messageTitle, description: messageDescription, logLevel: .info), messageActions)

        // Programatically navigate the user to the store screen
        // for .accessRequired and .accessExpired error cases
        // if the user can purchase a subscription
        let info = self.inAppPurchaseApplicationService.purchaseInfo()
        if info.canPurchase {
            switch accessError {
            case .accessRequired, .accessExpired:
                coordinator.goToStore(dismissModally: true, animated: false)
            default: ()
            }
        }
    }

    func didSelectSearch() {
        coordinator.showSearchView()
    }

    private func startReading(for learningCard: LearningCardIdentifier) {
        guard isLearningCardHtmlRendered else { return }
        readingRepository.startReading(for: learningCard)
    }

    private func endReading() {
        guard let currentItem = learningCardStack.currentItem?.learningCard, isLearningCardHtmlRendered else { return }
        let reading = readingRepository.endReading(for: currentItem)
        tracker.trackEndReading(for: currentItem, with: reading)
    }

    private func calculateFontSize(_ scale: Float) -> Float {
        let defaultFontSize: Float = 15.0

        return defaultFontSize * scale
    }

    private func updateToolbar() {
        openSectionCount = 0
        if let deeplink = learningCardStack.currentItem {
            view?.isFavorite = tagRepository.hasTag(.favorite, for: deeplink.learningCard)
            configureNavigationControls()
        }
    }

    func showError(title: String, message: String) {
        self.view?.showError(title: title, message: message)
    }
}

extension LearningCardPresenter: WebViewBridgeDelegate {

    func webViewBridge(bridge: WebViewBridge, didReceiveCallback callback: WebViewBridge.Callback) {
        switch callback {
        case .`init`:
            view?.setIsLoading(false)
            activateStudyObjective()
            injectWrongAnsweredQuestions()
            view?.changeHighlightingMode(learningCardOptionsRepository.isHighlightingModeOn)
            view?.changeHighYieldMode(learningCardOptionsRepository.isHighYieldModeOn)
            view?.changePhysikumFokusMode(learningCardOptionsRepository.isPhysikumFokusModeOn)
            view?.changeLearningRadarMode(learningCardOptionsRepository.isLearningRadarOn)
            view?.setPhysicianModeIsOn(userDataRepository.userStage == .physician)
            view?.setFontSize(size: calculateFontSize(deviceSettingsRepository.currentFontScale))

            // Reveal or blur trademarks based on the current user health care profession.
            userDataRepository.hasConfirmedHealthCareProfession ?? false ? view?.revealTrademarks() : view?.hideTrademarks()

            if remoteConfigRepository.pharmaDosageTooltipV1Enabled {
                // Reveal new dosage entitities if enabled
                view?.revealDosages()
            }

            isLearningCardHtmlRendered = true

            if let learningCardIdentifier = learningCardStack.currentItem?.learningCard {
                self.setExtensions(for: learningCardIdentifier)
                self.setSharedExtensions(for: learningCardIdentifier)
                // Create a reading for this learning card opening.
                self.startReading(for: learningCardIdentifier)
                self.tracker.trackStartReading(for: learningCardIdentifier)
            }

        case .closePopover: break
        case .openLearningCard(let learningCard):
            // WORKAROUND:
            // Because of navigate(to:) method is used from pharma and articles,
            // article to article navigation is tracked here if it is not coming from a snippet
            // We also don't want to track article selected event when the anchors selected within the same article so we are checking if it is not the same learning card
            let sameLearningCard = learningCard.learningCard.value == learningCardStack.currentItem?.learningCard.value
            let snippet = try? snippetRepository.snippet(for: learningCard)

            if snippet == nil, !sameLearningCard {
                tracker.trackArticleSelected()
            }

            // This is part of an experiment that shows the monographs screen directly to US clinicians
            // (instead of the the phrasionary + pharma learning card combination)
            // when they tap on a medication name.
            // It's basically the same as tapping a pharma pill but without the popup before presenting the monograph
            // See here for more info: https://miamed.atlassian.net/browse/PHEX-1351
            if let snippet,
               appConfiguration.appVariant == .knowledge,
               userDataRepository.userStage == .physician,
               let replacements = remoteConfigRepository.medicationLinkReplacements,
               let replacement = replacements.first(where: { $0.snippet == snippet.identifier }) {
                coordinator.navigate(to: MonographDeeplink(monograph: replacement.monograph))
                tracker.trackMonographExperimentLink(for: learningCard.learningCard,
                                                     monographID: replacement.monograph,
                                                     snippetID: snippet.identifier)
            } else {
                coordinator.navigate(to: learningCard, snippetAllowed: true)
            }

        case .showTable(let htmlDocument):
            coordinator.showTable(htmlDocument: htmlDocument, tracker: tracker)
        case .showPopover(let htmlDocument, let tooltipType):
            htmlSizeCalculationService.calculateSize(for: htmlDocument, width: AppConfiguration.shared.popoverWidth) { [weak self] htmlContentSize in
                guard let self = self else { return }
                self.coordinator.showPopover(htmlDocument: htmlDocument, tracker: self.tracker, preferredContentSize: htmlContentSize)
            }
            tracker.trackTooltipOpen(tooltipType: tooltipType)
        case .showImageGallery(let galleryDeeplink):
            imageTapped(galleryIdentifier: galleryDeeplink.gallery, imageOffset: galleryDeeplink.imageOffset)
        case .commitFeedback(let feedbackDeeplink):
            coordinator.showUserFeedback(for: feedbackDeeplink)
        case .editExtension(let sectionIdentifier):
            guard let learningCard = learningCardStack.currentItem?.learningCard else { return }
            coordinator.showExtensionView(for: learningCard, and: sectionIdentifier)
        case .sendMessageToUser(let userIdentifier):
            guard let user = sharedExtensionRepository.user(with: userIdentifier) else { return }
            guard let userEmail = user.email else {
                assertionFailure("User with this shared extension doesn't have an email address!")
                return
            }
            coordinator.sendEmail(to: userEmail) { [weak self] error in
                self?.view?.presentMessage(error, actions: [.dismiss])
            }
        case .manageSharedExtensions:
            coordinator.showManageSharedExtensionsView()
        case .showVideo(let video):
            coordinator.navigate(to: video.url, tracker: tracker)
        case .onSectionOpened(let learningCardAnchorIdentifier):
            // The scenario for ".onSectionClosed" (see comment below)
            // does not apply here since this can only be triggered when
            // * all sections are closed
            // * or single sections
            // ... thus, not throwing off the state
            openSectionCount += 1
            tracker.trackSectionOpened(sectionID: learningCardAnchorIdentifier.description)
        case .onSectionClosed(let learningCardAnchorIdentifier):
            // This is also called for closed sections, hence need to make sure it does not become negative
            // because this will throw off the state
            // To see why this is required, open a couple of sections (not all) and then tap
            // "collapse all" - this will be called for all sections ...
            openSectionCount = max(openSectionCount - 1, 0)
            tracker.trackSectionClosed(sectionID: learningCardAnchorIdentifier.description)
        case .blurredTrademarkTapped:
            view?.showDisclaimerDialog { [weak self] isConfirmed in
                guard let self = self else { return }
                isConfirmed ? self.view?.revealTrademarks() : self.view?.hideTrademarks()
                self.userDataRepository.hasConfirmedHealthCareProfession = isConfirmed
                self.userDataClient.setHealthcareProfession(isConfirmed: isConfirmed) { _ in
                    // Ignore any error: If the request fails The dialog will just come up again next time.
                    // This is sent here immediately and not synced via UserDataSynchronizer
                    // cause there is no timestamp for this property, so the synchronizer
                    // would always use the value from the web, which would then discard
                    // the choice the user made here. Just pushing it directly solves the issue.
                }
            }
        case .dosageTapped(let dosageID):
            if remoteConfigRepository.pharmaDosageTooltipV1Enabled {
                coordinator.showPopover(for: dosageID, tracker: tracker)
            }
        }
    }
}
