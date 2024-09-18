//
//  RootCoordinator.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/23/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Networking
import UIKit
import Localization

/// @mockable
protocol RootCoordinatorType: Coordinator {
    func navigate(to deepLink: Deeplink)
    func navigateToTagList(with type: Tag)
    func showStartupDialogs()
}

protocol RootCoordinatorDelegate: AnyObject {
    func didStart()
    func didStop()
}

final class RootCoordinator: Coordinator, RootCoordinatorType {

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private weak var rootViewController: RootViewController?
    private weak var rootPresenter: RootPresenter?

    private var manualUpdateStateErrorPresenter: LibraryDownloadStateErrorPresenterType?
    private var errorPresenter: UIAlertMessagePresenter?
    private let analyticsTracking: TrackingType
    private let deepLinkService: DeepLinkServiceType
    private let featureFlagRepository: FeatureFlagRepositoryType

    private weak var delegate: RootCoordinatorDelegate?

    private weak var searchCoordinator: SearchCoordinator?

    // Must remain a strong reference when coordinator
    // is active because this is the only one.
    private var startupDialogsCoordinator: StartupDialogCoordinator?

    private var searchTransition: SearchPresentationTransitioningManager?

    private func showSearchView(completion: @escaping () -> Void) {
        guard let rootViewController = rootViewController,
              searchCoordinator == nil else { return completion() }

        searchTransition = SearchPresentationTransitioningManager(rootViewController: rootViewController)
        let searchNavigationController = UINavigationController()
        searchNavigationController.transitioningDelegate = searchTransition
        searchNavigationController.modalPresentationStyle = .custom
        let searchCoordinator = SearchCoordinator(searchNavigationController, searchDelegate: self)
        searchCoordinator.start(animated: true)
        UIViewController.openViewControllerAsTopMost(searchNavigationController, completion: completion)
        self.searchCoordinator = searchCoordinator
    }

    private lazy var dashboardCoordinator: DashboardCoordinator = {
        DashboardCoordinator(Self.createNavigationViewController(hasThemeBackgroundColor: false), rootCoordinator: self)
    }()

    private lazy var libraryCoordinator = {
        LibraryCoordinator(
            Self.createNavigationViewController(hasThemeBackgroundColor: true),
            rootCoordinator: self
        )
    }()

    private lazy var listsCoordinator: ListsCoordinator = {
        ListsCoordinator(
            Self.createNavigationViewController(hasThemeBackgroundColor: false),
            rootCoordinator: self
        )
    }()

    private lazy var settingsCoordinator: SettingsCoordinator = {
        SettingsCoordinator(
            Self.createNavigationViewController(hasThemeBackgroundColor: false)
        )
    }()

    private lazy var coordinators: [Coordinator] = {
        [dashboardCoordinator, libraryCoordinator, listsCoordinator, settingsCoordinator]
    }()

    init(
        _ navigationController: UINavigationController,
        deepLinkService: DeepLinkServiceType,
        analyticsTracking: TrackingType = resolve(),
        featureFlagRepository: FeatureFlagRepositoryType = resolve()
    ) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.deepLinkService = deepLinkService
        self.analyticsTracking = analyticsTracking
        self.featureFlagRepository = featureFlagRepository
    }

    func start(animated: Bool) {
        let rootPresenter = RootPresenter(coordinator: self, deepLinkService: deepLinkService)
        self.rootPresenter = rootPresenter
        delegate = rootPresenter
        let rootViewController = RootViewController(presenter: rootPresenter)

        manualUpdateStateErrorPresenter = LibraryDownloadStateErrorPresenter()
        errorPresenter = UIAlertMessagePresenter(presentingViewController: rootViewController)
        manualUpdateStateErrorPresenter?.messagePresenter = errorPresenter

        navigationController.pushViewController(rootViewController, animated: animated)
        coordinators.forEach { $0.start(animated: false) }
        rootViewController.viewControllers = coordinators.map { $0.rootNavigationController }

        self.rootViewController = rootViewController

        analyticsTracking.track(.dashboardPageLoaded)
        delegate?.didStart()
    }

    func stop(animated: Bool) {
        coordinators.forEach { $0.stop(animated: animated) }
        navigationController.dismissAndPopAll(animated: animated)
        delegate?.didStop()
    }

    func showStartupDialogs() {
        startupDialogsCoordinator = StartupDialogCoordinator(self.rootNavigationController, delegate: self)
        startupDialogsCoordinator?.start(animated: true)
    }

}

extension RootCoordinator: StartupDialogCoordinatorDelegate {
    func didFinishStartupDialogs() {
        self.startupDialogsCoordinator = nil
    }
}

extension RootCoordinator {
    private static func createNavigationViewController(hasThemeBackgroundColor: Bool) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.view.backgroundColor = hasThemeBackgroundColor ? ThemeManager.currentTheme.backgroundColor : .white
        return navigationController
    }
}

extension RootCoordinator: SearchDelegate {
    func navigate(to learningCard: LearningCardDeeplink) {
        self.libraryCoordinator.showLearningCard(learningCard)
    }

    func navigate(to pharmaCard: PharmaCardDeeplink) {
        self.libraryCoordinator.showPharmaCard(pharmaCard)
    }

    func navigate(to monograph: MonographDeeplink) {
        self.libraryCoordinator.showMonograph(monograph)
    }

    func navigateToTagList(with type: Tag) {
        rootPresenter?.switchTo(.lists)
        switch type {
        case .opened: listsCoordinator.openRecents()
        case .favorite: listsCoordinator.openFavourites()
        case .learned: listsCoordinator.openLearned()
        }
    }

    func dismissSearchView(completion: (() -> Void)? = nil) {
        searchCoordinator?.rootNavigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.searchCoordinator = nil
            completion?()
        }
    }
}

extension RootCoordinator {

    func navigate(to deepLink: Deeplink) {
        switch deepLink {
        case .login:
            break // Nothing to do, login links only open the app
        case let .learningCard(link):
            libraryCoordinator.showLearningCard(link)
        case let .pharmaCard(link):
            libraryCoordinator.showPharmaCard(link)
        case let .search(link, _):
            self.showSearchView {
                guard let searchDeepLink = link else { return }
                self.searchCoordinator?.navigate(to: searchDeepLink)
            }
        case let .monograph(link):
            libraryCoordinator.showMonograph(link)
        case let .unsupported(url):
            handleUnsupportedDeeplink(webpageURL: url)
        case let .uncommitedSearch(link):
            self.showSearchView { }
            self.searchCoordinator?.navigate(to: link)
        case .settings(let link):
            self.showSettings(screen: link.screen)
        case .pocketGuides:
            self.dashboardCoordinator.navigateToPocketGuides()
        case .productKey(let link):
            showSettings(screen: .productKey(link.code))
        }
    }

    private func showSettings(screen: SettingsDeeplink.Screen) {
        func process() {
            let itemType: Settings.ItemType
            switch screen {
            case .appearance:
                itemType = .appearance
            case .productKey(let key):
                itemType = .redeemCode(code: key)
            }
            settingsCoordinator.goToViewController(of: itemType, animated: false)
            rootPresenter?.switchTo(.settings)
        }
        if searchCoordinator != nil {
            dismissSearchView { process() }
        } else {
            process()
        }
    }

    private func handleUnsupportedDeeplink(webpageURL: URL) {
        let messageAlertPresenter = UIAlertMessagePresenter(presentingViewController: UIViewController.topMost(of: rootNavigationController))

        let message = PresentableMessage(
            title: L10n.Error.Deeplink.title,
            description: L10n.Error.Deeplink.message,
            logLevel: .info
        )

        let yesAction = MessageAction(title: L10n.Generic.yes, style: .normal) { [unowned self] () -> Bool in
            let webCoordinator = WebCoordinator(self.rootNavigationController, url: webpageURL, navigationType: .internal(modalPresentationStyle: .fullScreen))
            webCoordinator.start(animated: true)
            return true
        }

        let noAction = MessageAction(title: L10n.Generic.no, style: .normal, handlesError: true)

        messageAlertPresenter.present(message, actions: [noAction, yesAction])
    }
}
