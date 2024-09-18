//
//  DashboardCoordinator.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 16.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Networking
import UIKit
import DesignSystem
import Localization

/// @mockable
protocol DashboardCoordinatorType: Coordinator {
    func navigate(to deepLink: Deeplink)
    func navigateToContentList(for clinicalTool: ClinicalTool)
    func preloadPocketGuides()
    func navigateToPocketGuides()
    func navigate(to imageResourceIdentifier: ImageResourceIdentifier)
    func navigate(to externalAddition: ExternalAdditionIdentifier)
    func navigateToCompleteRecentsList()
    func navigateToStore()
    func showUrl(url: URL)
    func navigateToUserStageSettings()
    func navigateToContentCardFeed(cards: [BrazeContentCard])
    func showAppToWebURL(_ url: URL, completion: @escaping () -> Void)
}

final class DashboardCoordinator: DashboardCoordinatorType {

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private let rootCoordinator: RootCoordinatorType
    private let userDataClient: UserDataClient
    private let authenticationClient: AuthenticationClient
    private let appConfiguration: Configuration

    private var dashboardPresenter: DashboardPresenter?
    private var pocketGuidesController: UIViewController?

    init(_ navigationController: UINavigationController,
         rootCoordinator: RootCoordinatorType,
         userDataClient: UserDataClient = resolve(),
         authenticationClient: AuthenticationClient = resolve(),
         appConfiguration: Configuration = AppConfiguration.shared
    ) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.rootCoordinator = rootCoordinator
        self.userDataClient = userDataClient
        self.authenticationClient = authenticationClient
        self.appConfiguration = appConfiguration
    }

    func start(animated: Bool) {

        let dashboardPresenter = DashboardPresenter(coordinator: self,
                                                    maxNumberOfRecents: 5,
                                                    listTrackingProvider: DashboardListTracker())
        self.dashboardPresenter = dashboardPresenter

        let dashboardViewController = DashboardViewController(presenter: dashboardPresenter)

        navigationController.pushViewController(dashboardViewController, animated: animated)
    }

    func stop(animated: Bool) {
        navigationController.dismissAndPopAll(animated: animated)
    }
}

extension DashboardCoordinator {
    func navigate(to deepLink: Deeplink) {
        rootCoordinator.navigate(to: deepLink)
    }
}

extension DashboardCoordinator: ListCoordinatorType {
    func navigate(to learningCard: LearningCardDeeplink) {
        rootCoordinator.navigate(to: .learningCard(learningCard))
    }

    func navigateToContentList(for clinicalTool: ClinicalTool) {
        let presenter = ContentListPresenter(clinicalTool: clinicalTool, coordinator: self)
        var controller: UIViewController

        switch clinicalTool {
        case .pocketGuides:
            navigateToPocketGuides()
            return
        case .drugDatabase, .guidelines:
            controller = ContentListTableViewController(presenter: presenter)
        case .flowcharts, .calculators:
            controller = ContentListCollectionViewController(presenter: presenter)
        }
        navigationController.pushViewController(controller, animated: true)
    }

    func navigateToPocketGuides() {

        var controller: UIViewController
        if let pocketGuidesVC = pocketGuidesController {
            controller = pocketGuidesVC
        } else {
            controller = createPocketGuidesController()
        }
        navigationController.pushViewController(controller, animated: true)
    }

    func createPocketGuidesController() -> UIViewController {
        var forcedUrl: String?
        #if Debug || QA
        if let url = PocketGuidesURLPlugin.urlValue {
            forcedUrl = url
        }
        #endif

        let presenter = DeeplinkAwareWebviewPresenter(
            lastPathComponent: "pocketGuides",
            queryParameters: ["isEmbeddedInApp": "true"],
            forcedInitialURL: forcedUrl,
            coordinator: self)

        let title = L10n.Dashboard.Sections.ClinicalTools.PocketGuides.title
        let controller = DeeplinkAwareWebViewController(presenter: presenter,
                                                        initialTitle: title,
                                                        dismissClosure: { [weak self] in
            self?.navigationController.navigationController.interactivePopGestureRecognizer?.delegate = self?.navigationController
        })

        return controller
    }

    func preloadPocketGuides() {
        if self.pocketGuidesController == nil {
            // WORKAROUND: Loading the pocket guides
            // appToWeb link takes a long time and
            // breaks the native experience feel.
            // So we are manually preloading
            // the content of the viewController
            self.pocketGuidesController = createPocketGuidesController()
            _ = self.pocketGuidesController?.view
        }
    }

    func navigate(to imageResourceIdentifier: ImageResourceIdentifier) {
        let galleryNavigationController = UINavigationController()
        galleryNavigationController.modalPresentationStyle = .fullScreen
        let galleryCoordinator = GalleryCoordinator(galleryNavigationController,
                                                    galleryRepository: GalleryRepository(),
                                                    learningCardTitle: nil)
        galleryCoordinator.start(animated: true)
        galleryCoordinator.go(to: imageResourceIdentifier)
        navigationController.present(galleryNavigationController, animated: true)

        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done) { [weak self] _ in
            self?.navigationController.dismissPresented(animated: true) {
                galleryCoordinator.stop(animated: false)
            }
        }
        galleryNavigationController.topViewController?.navigationItem.leftBarButtonItem = doneBarButtonItem
    }

    func navigate(to externalAddition: ExternalAdditionIdentifier) {
        let externalMediaNavigationController = UINavigationController()
        let externalMediaCoordinator = ExternalMediaCoordinator(externalMediaNavigationController)
        externalMediaCoordinator.start(animated: false)
        externalMediaCoordinator.openExternalAddition(with: externalAddition)

        navigationController.present(externalMediaNavigationController)
    }

    func navigateToCompleteRecentsList() {
        rootCoordinator.navigateToTagList(with: .opened)
    }

    func navigateToContentCardFeed(cards: [BrazeContentCard]) {
        #if DEBUG || QA
        let presenter = ContentCardFeedPresenter(cards: cards)
        let dataSource = ContentCardFeedDataSource()
        let controller = GenericListTableViewController(
            dataSource: dataSource,
            presenter: presenter)
        dataSource.delegate = controller

        controller.title = "Content Card Feed"
        navigationController.pushViewController(controller,
                                                animated: true)
        #endif
    }

    func showUrl(url: URL) {
        let webCoordinator = WebCoordinator(rootNavigationController,
                                            url: url,
                                            navigationType: .internal(modalPresentationStyle: .overFullScreen))
        webCoordinator.start(animated: true)
    }

    func showAppToWebURL(_ url: URL, completion: @escaping () -> Void) {
        authenticationClient.issueOneTimeToken(timeout: 2) { [weak self] result in
            guard let self = self else { return }
            completion()
            var url: URL
            switch result {
            case .success(let token):
                url = self.appConfiguration.cmeURL.adding(query: ["token": token.token])
            case .failure:
                url = self.appConfiguration.cmeURL
            }
            UIApplication.shared.open(url)
        }
    }

    func navigateToStore() {
        let navigationController = UINavigationController()
        let closeButtonItem = UIBarButtonItem(image: Asset.closeButton.image, style: .plain, target: self, action: #selector(dismissStoreView))

        let coordinator = InAppPurchaseCoordinator(navigationController)
        coordinator.start(animated: true)
        coordinator.rootNavigationController.viewControllers.first?.navigationItem.leftBarButtonItem = closeButtonItem
        self.navigationController.present(navigationController, animated: true)
    }

    func navigateToUserStageSettings() {
        let repository = SettingsUserStageRepository(userDataClient: userDataClient)
        let presenter = SettingsUserStagePresenter(repository: repository, coordinator: self, userStages: AppConfiguration.shared.availableUserStages, referer: .dashboard)
        presenter.delegate = self

        let controller = UserStageViewController(presenter: presenter)
        let closeButtonItem = UIBarButtonItem(image: Asset.closeButton.image, style: .plain, target: self, action: #selector(dismissStageSettings))
        controller.navigationItem.leftBarButtonItem = closeButtonItem

        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .overFullScreen
        self.navigationController.present(navigationController, animated: true)
    }

    @objc private func dismissStoreView() {
        navigationController.dismissPresented(animated: true)
    }

    @objc private func dismissStageSettings() {
        navigationController.dismissPresented(animated: true)
    }
}

extension DashboardCoordinator: UserStageCoordinatorType {
    func openURL(_ url: URL) {
        showUrl(url: url)
    }
}

extension DashboardCoordinator: UserStagePresenterDelegate {

    func didSaveUserStage(_ stage: UserStage) {
        dismissStageSettings()
    }
}

extension DashboardCoordinator: DeeplinkAwareWebviewCoordinatorType {
    func openInternally(url: URL) {
        showUrl(url: url)
    }
}
