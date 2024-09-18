//
//  SettingsCoordinator.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/23/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import AcknowList
import Common
import Domain
import Networking
import SafariServices
import Localization

/// @mockable
protocol SettingsCoordinatorType: Coordinator {
    func goToViewController(of type: Settings.ItemType, animated: Bool)
    func openInApp(_ url: URL)
    func openLibrariesView()
    func goToAccountDeletion(completion: @escaping () -> Void)
    func goBackToSettings()
}

final class SettingsCoordinator: NSObject, SettingsCoordinatorType {

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private let libraryUpdater: LibraryUpdaterType
    private let authorizationRepository: AuthorizationRepositoryType
    private let learningCardClient: LearningCardLibraryClient
    private let authenticationClient: AuthenticationClient
    private let userDataClient: UserDataClient
    private var libraryDownloadStatePresenter: LibraryDownloadStatePresenterType?
    private let supportApplicationService: SupportApplicationService
    private let supportRequestFactory: SupportRequestFactory

    init(_ navigationController: UINavigationController,
         libraryUpdater: LibraryUpdaterType = resolve(),
         authorizationRepository: AuthorizationRepositoryType = resolve(),
         learningCardClient: LearningCardLibraryClient = resolve(),
         authenticationClient: AuthenticationClient = resolve(),
         userDataClient: UserDataClient = resolve(),
         supportApplicationService: SupportApplicationService = resolve(),
         supportRequestFactory: SupportRequestFactory = resolve()) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.libraryUpdater = libraryUpdater
        self.authorizationRepository = authorizationRepository
        self.learningCardClient = learningCardClient
        self.userDataClient = userDataClient
        self.authenticationClient = authenticationClient
        self.supportApplicationService = supportApplicationService
        self.supportRequestFactory = supportRequestFactory

        super.init()

        navigationController.delegate = self
    }

    func start(animated: Bool) {
        let settingsPresenter = SettingsPresenter(coordinator: self, libraryUpdater: libraryUpdater, userDataRepositoryType: resolve(), authorizationRepository: authorizationRepository)
        let settingsTableViewController = SettingsTableViewController(presenter: settingsPresenter)
        navigationController.pushViewController(settingsTableViewController, animated: animated)

        libraryDownloadStatePresenter = LibraryDownloadStatePresenter(libraryUpdater: libraryUpdater)
        libraryDownloadStatePresenter?.view = navigationController.navigationController
    }

    func stop(animated: Bool) {
        navigationController.dismissAndPopAll(animated: animated)
    }

    private func open(_ url: URL) {
        UIApplication.shared.open(url)
    }
}

extension SettingsCoordinator {
    func goToViewController(of type: Settings.ItemType, animated: Bool = true) {
        switch type {
        case .accountSettings:
            let presenter = AccountSettingsPresenter(coordinator: self, authorizationRepository: authorizationRepository, learningCardClient: learningCardClient, authenticationClient: authenticationClient)
            navigationController.pushViewController(AccountSettingsViewController.viewController(with: presenter), animated: animated)
        case .library:
            let presenter = LibrariesSettingsPresenter(libraryUpdater: libraryUpdater)
            let librarySettingsTableViewController = LibrariesSettingsTableViewController.viewController(with: presenter)
            navigationController.pushViewController(librarySettingsTableViewController, animated: animated)
        case .userstage:
            let presenter = SettingsUserStagePresenter(repository: SettingsUserStageRepository(userDataClient: userDataClient), coordinator: self, userStages: AppConfiguration.shared.availableUserStages, referer: .settings)
            let controller = UserStageViewController(presenter: presenter)
            navigationController.pushViewController(controller, animated: animated)
        case .shop:
            let coordinator = InAppPurchaseCoordinator(rootNavigationController)
            coordinator.start(animated: true)
        case .studyobjective:
            let presenter = SettingsStudyObjectivePresenter(repository: SettingsStudyObjectiveRepository(userDataClient: userDataClient))
            let controller = StudyObjectiveViewController(presenter: presenter)
            navigationController.pushViewController(controller, animated: animated)
        case .supportus: supportApplicationService.showHelpCenterOverviewViewController(on: navigationController.navigationController, requestType: supportRequestFactory.standardSupportRequest())
        case .appearance:
            let presenter = AppearanceSettingsPresenter()
            let controller = AppearanceSettingsTableViewController(presenter: presenter)
            navigationController.pushViewController(controller, animated: animated)
        case .qbank:
            let configuration: URLConfiguration = AppConfiguration.shared
            open(configuration.qBankAppStoreLink)
        case .about:
            let presenter = AboutPresenter(coordinator: self)
            let controller = AboutViewController(presenter: presenter)
            navigationController.pushViewController(controller, animated: animated)
        case .redeemCode(let code):
            let presenter = RedeemCodePresenter(code: code, coordinator: self)
            let controller = RedeemCodeViewController(presenter: presenter)
            navigationController.pushViewController(controller, animated: animated)
        default:
            break
        }
    }

    func openLibrariesView() {
        // This parses SPM's "Package.resolved" file to gather licence information
        // Hence this is the reason why "Package.resolved" is added as a file to the app target
        // Hopefully you arrived here after wondering about exactly that and doing
        // a full text search in the project. In case you did not, here's an assertion...
        assert(Bundle.main.url(forResource: "Package", withExtension: "resolved") != nil)
        let licencesViewController = AmbossAcknowledeListViewController()
        licencesViewController.view.backgroundColor = ThemeManager.currentTheme.backgroundColor
        licencesViewController.title = L10n.Licenses.title
        navigationController.pushViewController(licencesViewController, animated: true)
    }

    func openInApp(_ url: URL) {
        let webCoordinator = WebCoordinator(rootNavigationController, url: url, navigationType: .internal(modalPresentationStyle: .overFullScreen))
        webCoordinator.start(animated: true)
    }

    func goToAccountDeletion(completion: @escaping () -> Void) {
        let presenter = AppToWebPresenter(appConfiguration: AppConfiguration.shared, lastPathComponent: "deleteaccount", queryParameters: ["no-menu": "1"])
        let viewController = WebViewController(presenter: presenter)

        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done) { [weak self] _ in
            self?.navigationController.navigationController.dismiss(animated: true)
            completion()
        }
        viewController.navigationItem.leftBarButtonItem = doneBarButtonItem

        let webViewNavigationController = UINavigationController(rootViewController: viewController)
        webViewNavigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationController.present(webViewNavigationController, animated: true)
    }

    func goBackToSettings() {
        navigationController.popToRoot(animated: true)
    }
}

extension SettingsCoordinator: UserStageCoordinatorType {
    func openURL(_ url: URL) {
        openInApp(url)
    }
}

extension SettingsCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        .portrait
    }
 }
