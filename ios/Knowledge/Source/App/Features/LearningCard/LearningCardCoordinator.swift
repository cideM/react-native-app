//
//  LearningCardCoordinator.swift
//  Knowledge
//
//  Created by CSH on 28.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import MessageUI
import Networking
import UIKit

final class LearningCardCoordinator: NSObject, LearningCardCoordinatorType {

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private let libraryCoordinator: LibraryCoordinatorType
    private let libraryRepository: LibraryRepositoryType
    private let learningCardOptionsRepository: LearningCardOptionsRepositoryType
    private let userDataRepository: UserDataRepositoryType
    private let snippetRepository: SnippetRepositoryType
    private let mediaClient: MediaClient
    private let tagRepository: TagRepositoryType
    private var learningCardPresenter: LearningCardPresenterType?
    private let appConfiguration: URLConfiguration
    private let analyticsTracker: TrackingType
    private let rootCoordinator: RootCoordinator

    private weak var presentedPopoverViewController: UIViewController?

    private let galleryRepository: GalleryRepository

    init(
        _ navigationController: UINavigationController,
        libraryCoordinator: LibraryCoordinatorType,
        libraryRepository: LibraryRepositoryType = resolve(),
        learningCardOptionsRepository: LearningCardOptionsRepositoryType = resolve(),
        userDataRepository: UserDataRepositoryType = resolve(),
        mediaClient: MediaClient = resolve(),
        tagRepository: TagRepositoryType = resolve(),
        appConfiguration: Configuration = AppConfiguration.shared,
        analyticsTracker: TrackingType = resolve(),
        rootCoordinator: RootCoordinator
    ) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.libraryCoordinator = libraryCoordinator
        self.libraryRepository = libraryRepository
        self.learningCardOptionsRepository = learningCardOptionsRepository
        self.userDataRepository = userDataRepository
        self.snippetRepository = SnippetRepository()
        self.mediaClient = mediaClient
        self.tagRepository = tagRepository
        self.appConfiguration = appConfiguration
        self.analyticsTracker = analyticsTracker
        self.rootCoordinator = rootCoordinator

        self.galleryRepository = GalleryRepository(mediaClient: mediaClient)
    }

    func start(animated: Bool) {

        let learningCardTracker = LearningCardTracker(
            trackingProvider: analyticsTracker,
            libraryRepository: libraryRepository,
            learningCardOptionsRepository: learningCardOptionsRepository,
            learningCardStack: libraryRepository.learningCardStack,
            userStage: userDataRepository.userStage)

        let learningCardPresenter = LearningCardPresenter(
            coordinator: self,
            libraryRepository: libraryRepository,
            learningCardStack: libraryRepository.learningCardStack,
            learningCardOptionsRepository: learningCardOptionsRepository,
            userDataRepository: userDataRepository,
            tagRepository: tagRepository,
            learningCardShareRepository: LearningCardShareRepostitory(configuration: AppConfiguration.shared),
            galleryRepository: galleryRepository,
            snippetRepository: snippetRepository,
            tracker: learningCardTracker)

        let handler = LibraryArchiveSchemeHandler()
        let learningCardViewController = LearningCardViewController(presenter: learningCardPresenter, learningCardTracker: learningCardTracker, handler: handler)

        navigationController.pushViewController(learningCardViewController, animated: animated)
        self.learningCardPresenter = learningCardPresenter
    }

    func stop(animated: Bool) {
        self.learningCardPresenter = nil
        navigationController.dismissAndPopAll(animated: animated)
    }

    func navigate(to deeplink: LearningCardDeeplink, snippetAllowed: Bool, shouldPopToRoot: Bool) {
        closePopover { [weak self] in
            self?.closeLearningCardOptions()
            self?.closeSnippetView()
            if shouldPopToRoot {
                self?.navigationController.popToRoot(animated: true)
            } else {
                // If an article gets opened via a "real" deeplink and we are
                // presenting not just the root of the nav e.g image vc, we need
                // to pop the topmost vc to not cover the updated article.
                self?.navigationController.navigationController.popViewController(animated: false)
            }
            if snippetAllowed, let snippet = try? self?.snippetRepository.snippet(for: deeplink) {
                self?.showSnippetView(with: snippet, for: .learningCard(deeplink))
            } else {
                self?.learningCardPresenter?.go(to: deeplink)
            }
        }
    }

    func navigate(to pharmaCard: PharmaCardDeeplink) {
        closePopover {
            self.libraryCoordinator.showPharmaCard(pharmaCard)
        }
    }

    func navigate(to monograph: MonographDeeplink) {
        closePopover {
            self.libraryCoordinator.showMonograph(monograph)
        }
    }

    func showTable(htmlDocument: HtmlDocument, tracker: LearningCardTracker) {
        closePopover()
        closeLearningCardOptions()
        let presenter = TableDetailPresenter(coordinator: self, document: htmlDocument, galleryRepository: galleryRepository, tracker: tracker)
        let handler = LibraryArchiveSchemeHandler()
        let view = TableDetailViewController(presenter: presenter, handler: handler)
        navigationController.pushViewController(view, animated: true)
    }

    func showPopover(htmlDocument: HtmlDocument, tracker: LearningCardTracker, preferredContentSize: CGSize) {
        closePopover()
        closeLearningCardOptions()

        let presenter = PopoverPresenter(coordinator: self, document: htmlDocument, galleryRepository: galleryRepository, tracker: tracker)
        let view = PopoverViewController(presenter: presenter, handler: LibraryArchiveSchemeHandler())
        view.preferredContentSize = preferredContentSize

        presentPopover(with: view)
    }

    func showPopover(for dosageIdentifier: DosageIdentifier, tracker: LearningCardTracker) {
        closePopover()
        closeLearningCardOptions()
        let presenter = DosagePopoverPresenter(libraryCoordinator: libraryCoordinator, learningCardCoordinator: self, dosageIdentifier: dosageIdentifier, tracker: tracker)
        let handler = LibraryArchiveSchemeHandler()
        let view = DosagePopoverViewController(presenter: presenter, handler: handler)
        presentPopover(with: view)
    }

    func showError(title: String, message: String) {
        self.closePopover { [weak self] in
            self?.learningCardPresenter?.showError(title: title, message: message)
        }
    }

    func navigateToUserStageSettings() {
        let repository = SettingsUserStageRepository(userDataClient: resolve())
        let presenter = SettingsUserStagePresenter(repository: repository, coordinator: self, userStages: AppConfiguration.shared.availableUserStages, referer: .articleSettings)
        presenter.delegate = self

        let controller = UserStageViewController(presenter: presenter)
        let closeButtonItem = UIBarButtonItem(image: Asset.closeButton.image, style: .plain, target: self, action: #selector(dismissStageSettings))
        controller.navigationItem.leftBarButtonItem = closeButtonItem

        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .overFullScreen
        self.navigationController.present(navigationController, animated: true)
    }

    func closePopover() {
        closePopover {}
    }

    private var cardTransition: CardPresentationTransitioningManager?
    private var isFontSliderTrackingObservation: NSKeyValueObservation?

    func showLearningCardOptions(tracker: LearningCardTracker) {
        closePopover()
        closeLearningCardOptions()
        let presenter = LearningCardOptionsPresenter(coordinator: self,
                                                     optionsRepository: learningCardOptionsRepository,
                                                     userDataRepository: userDataRepository,
                                                     deviceSettingRepository: resolve(),
                                                     learningCardStack: libraryRepository.learningCardStack,
                                                     learningCardShareRepository: LearningCardShareRepostitory(configuration: AppConfiguration.shared),
                                                     tagRepository: tagRepository,
                                                     tracker: tracker)
        let viewController = LearningCardOptionsViewController(presenter: presenter)
        let wrapper = PopoverContainerViewController(child: viewController)

        cardTransition = CardPresentationTransitioningManager(edge: .bottom, fullScreenWidth: false)
        wrapper.modalPresentationStyle = .custom
        wrapper.transitioningDelegate = cardTransition

        self.navigationController.present(wrapper)

        let cardPresentationController = wrapper.presentationController as? CardPresentationController
        presenter.setfontSliderTrackingCallback { [weak cardPresentationController] isTracking in
            cardPresentationController?.hideDimmingOverlay(isTracking)

            UIView.animate(withDuration: 0.33, delay: 0, options: [.curveLinear]) { [weak wrapper, weak cardPresentationController] in
                wrapper?.updateBackground(isHidden: isTracking)
                cardPresentationController?.containerView?.layer.shadowColor = UIColor.black.cgColor
                cardPresentationController?.containerView?.layer.shadowOffset = CGSize(width: 0, height: 0.5)
                cardPresentationController?.containerView?.layer.shadowOpacity = isTracking ? 0.2 : 0
                cardPresentationController?.containerView?.layer.shadowRadius = 5
            }
        }
    }

    func closeLearningCardOptions() {
        navigationController.dismissPresented()
        isFontSliderTrackingObservation = nil
    }

    func showSnippetView(with snippet: Snippet, for deeplink: Deeplink) {
        let presenter = SnippetPresenter(coordinator: self, snippet: snippet, deeplink: deeplink, trackingProvider: ArticleSnippetTracker())
        let snippetViewController = SnippetViewController.viewController(with: presenter)
        let wrapper = PopoverContainerViewController(child: snippetViewController)

        cardTransition = CardPresentationTransitioningManager(edge: .bottom, fullScreenWidth: false)
        wrapper.modalPresentationStyle = .custom
        wrapper.transitioningDelegate = cardTransition

        self.navigationController.present(wrapper)
    }

    func closeSnippetView() {
        navigationController.dismissPresented()
    }

    func showImageGallery(_ galleryDeeplink: GalleryDeeplink, tracker: GalleryAnalyticsTrackingProviderType) {
        closePopover()
        closeLearningCardOptions()
        let galleryCoordinator = makeGalleryCoordinator(tracker: tracker)
        galleryCoordinator.start(animated: true)
        galleryCoordinator.go(to: galleryDeeplink)
    }

    func openURLExternally(_ url: URL) {
        let webCoordinator = WebCoordinator(rootNavigationController, url: url, navigationType: .external)
        webCoordinator.start(animated: true)
    }

    func openURLInternally(_ url: URL) {
        navigationController.dismissPresented(animated: false) { [weak self] in
            guard let self = self else { return }
            let webCoordinator = WebCoordinator(self.rootNavigationController, url: url, navigationType: .internal(modalPresentationStyle: .currentContext))
            webCoordinator.start(animated: true)
        }
    }

    func showUserFeedback(for deeplink: FeedbackDeeplink) {
        let feedbackController = FeedbackViewController(presenter: FeedbackPresenter(deepLink: deeplink, coordinator: self))
        let navigationController = UINavigationController.withBarButton(rootViewController: feedbackController, barButton: .cancel)
        self.navigationController.present(navigationController)
    }

    func dismissFeedbackView() {
        navigationController.dismissPresented()
    }

    func showExtensionView(for learningCard: LearningCardIdentifier, and section: LearningCardSectionIdentifier) {
        let presenter = EditExtensionPresenter(learningCard: learningCard, learningCardSectionIdentifier: section, coordinator: self)
        let view = EditExtensionViewController(presenter: presenter, library: libraryRepository.library)
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.modalPresentationStyle = .overFullScreen
        self.navigationController.present(navigationController)
    }

    @objc func dismissExtensionView() {
        navigationController.dismissPresented()
    }

    func showMiniMap(for learningCardIdentifier: LearningCardIdentifier, with currentModes: [String]) {
        let presenter = MiniMapPresenter(learningCardIdentifier: learningCardIdentifier, coordinator: self, currentModes: currentModes)
        let miniMapViewController = MiniMapTableViewController(presenter: presenter)

        cardTransition = CardPresentationTransitioningManager(edge: .right)
        miniMapViewController.modalPresentationStyle = .custom
        miniMapViewController.transitioningDelegate = cardTransition

        navigationController.present(miniMapViewController)
    }

    func dismissMiniMapView() {
        navigationController.dismissPresented()
    }

    func share(_ learningCardShareItem: LearningCardShareItem, completion: @escaping (Bool) -> Void) {
        closePopover()
        closeLearningCardOptions()
        guard let topViewController = self.navigationController.navigationController.topViewController else { return }
        let activityViewController = UIActivityViewController(activityItems: [learningCardShareItem], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { _, didShare, _, _ in completion(didShare) }

        topViewController.present(activityViewController, animated: true, completion: nil)

        if let popoverController = activityViewController.popoverPresentationController {
            let shareButtonView = topViewController.navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView
            popoverController.sourceView = shareButtonView ?? topViewController.view
            popoverController.sourceRect = shareButtonView?.frame ?? .zero
        }
    }

    func navigate(to externalAddition: ExternalAdditionIdentifier, tracker: GalleryAnalyticsTrackingProviderType) {
        closePopover { [weak self] in
            let externalMediaNavigationController = UINavigationController()
            let externalMediaCoordinator = ExternalMediaCoordinator(externalMediaNavigationController, galleryAnalyticsTrackingProvider: tracker)
            externalMediaCoordinator.start(animated: true)
            externalMediaCoordinator.openExternalAddition(with: externalAddition)

            self?.navigationController.present(externalMediaNavigationController)
        }
    }

    func navigate(to videoURL: URL, tracker: GalleryAnalyticsTrackingProviderType) {
        let externalMediaNavigationController = UINavigationController()
        let externalMediaCoordinator = ExternalMediaCoordinator(externalMediaNavigationController, galleryAnalyticsTrackingProvider: tracker)
        externalMediaCoordinator.start(animated: true)
        externalMediaCoordinator.openVideoWithoutCheckingForPermissions(with: videoURL)

        navigationController.present(externalMediaNavigationController)
    }

    func showManageSharedExtensionsView() {
        let presenter = ManageSharedExtensionsPresenter()
        let viewController = WebViewController(presenter: presenter)
        let externalMediaNavigationController = UINavigationController.withBarButton(rootViewController: viewController, barButton: .done)
        navigationController.present(externalMediaNavigationController)
    }

    func sendEmail(to emailAddress: String, onFailure: (EmailSendingError) -> Void) {
        guard MFMailComposeViewController.canSendMail() else {
            return onFailure(.noEmailClientSetup)
        }
        let composeEmailView = MFMailComposeViewController()
        composeEmailView.mailComposeDelegate = self
        composeEmailView.setToRecipients([emailAddress])
        navigationController.present(composeEmailView)
    }

    func navigateToURL(_ url: URL) {
        UIApplication.shared.open(url)
    }

    func showSearchView() {
        rootCoordinator.navigate(to: .search(nil))
    }

    func openQBankSessionCreation(for learningCard: LearningCardIdentifier) {
        openSessionCreationInQBankApp(for: learningCard) { [weak self] success in
            if !success {
                self?.openSessionCreationInAppToWebViewPresenter(for: learningCard)
            }
        }
    }

    func goToStore(dismissModally: Bool, animated: Bool) {
        // The "dismissPresented()" is only required for one specific edge case (as far as i know):
        // User does not have "meditricks" subscription and wants to open a meditricks image
        // Example: Search "Chorea huntinton" -> scroll down to meditricks -> open image -> press "buy subsription" button
        // The error here is presented modally (SubviewMessagePresenter) and the shop page can not be pushed on it (no nav controller)
        // Hence the modal must be dismissed and the shop page pushed one layer lower
        // The closure will be called always. If a modal existis or not.
        navigationController.dismissPresented { [weak self] in
            guard let self = self else { return }
            let coordinator = InAppPurchaseCoordinator(self.rootNavigationController,
                                                       dismissModally: dismissModally,
                                                       dismissCompletion: {
                self.libraryCoordinator.dismissLearningCard()
            })
            coordinator.start(animated: animated)
            self.analyticsTracker.track(.noAccessBuyLicense)
        }
    }
}

private extension LearningCardCoordinator {

    func makeGalleryCoordinator(tracker: GalleryAnalyticsTrackingProviderType) -> GalleryCoordinator {
        let galleryNavigationController = navigationController.navigationController
        return  GalleryCoordinator(galleryNavigationController,
                                   galleryRepository: galleryRepository,
                                   tracker: tracker,
                                   learningCardTitle: navigationController.navigationController.topViewController?.title)

    }

    func closePopover(_ completion: @escaping () -> Void) {
        if presentedPopoverViewController != nil {
            presentedPopoverViewController?.dismiss(animated: true) { [weak self] in
                self?.presentedPopoverViewController = nil
                completion()
            }
        } else {
            completion()
        }
    }

    func openSessionCreationInQBankApp(for learningCard: LearningCardIdentifier, completion: @escaping (Bool) -> Void) {
        let pathComponent = appConfiguration.qBankQuestionSessionPathComponent + learningCard.description
        let universalLink = appConfiguration.webBaseURL.appendingPathComponent(pathComponent).adding(query: appConfiguration.qBankQuestionSessionURLQueryItems) // Note: Remove 'query' (appConfiguration.qBankQuestionSessionURLQueryItems) in future releases. This parameter is only needed for backwards compatibility with older versions of Qbank.
        UIApplication.shared.open(universalLink, options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: true]) { success in
            completion(success)
        }
    }

    func openSessionCreationInAppToWebViewPresenter(for learningCard: LearningCardIdentifier) {
        let presenter = AppToWebPresenter(lastPathComponent: "createCustomSession", queryParameters: ["learningCardXid": learningCard.description, "isEmbeddedInApp": "false"])
        let controller = WebViewController(presenter: presenter)
        let webViewNavigationController = UINavigationController(rootViewController: controller)
        webViewNavigationController.modalPresentationStyle = .fullScreen
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissWebView))
        controller.navigationItem.leftBarButtonItem = doneBarButtonItem
        closeLearningCardOptions()
        navigationController.navigationController.present(webViewNavigationController, animated: true)
    }

    @objc func dismissWebView() {
        navigationController.navigationController.dismiss(animated: true)
    }

    func presentPopover(with view: UIViewController) {
        let wrapper = PopoverContainerViewController(child: view)
        cardTransition = CardPresentationTransitioningManager(edge: .bottom, fullScreenWidth: false)
        wrapper.modalPresentationStyle = .custom
        wrapper.transitioningDelegate = cardTransition

        presentedPopoverViewController = view
        navigationController.present(wrapper)
    }

    @objc private func dismissStageSettings() {
        navigationController.dismissPresented(animated: true)
    }
}

extension LearningCardCoordinator: MFMailComposeViewControllerDelegate {
    // unused:ignore mailComposeController
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        navigationController.dismissPresented()
    }
}

extension LearningCardCoordinator: SnippetLearningCardDisplayer {
    func navigate(to deeplink: LearningCardDeeplink, shouldPopToRoot: Bool) {
        navigate(to: deeplink, snippetAllowed: false, shouldPopToRoot: shouldPopToRoot)
    }
}

extension LearningCardCoordinator: UserStageCoordinatorType {
    func openURL(_ url: URL) {
        openURLInternally(url)
    }
}

extension LearningCardCoordinator: UserStagePresenterDelegate {
    func didSaveUserStage(_ stage: UserStage) {
        dismissStageSettings()
    }
}
