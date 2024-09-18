//
//  AuthenticationCoordinator.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 23.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Networking
import UIKit
import Localization

/// @mockable
protocol AuthenticationCoordinatorType: Coordinator {
    func goToUserStageSelection()
    func goToPurposeSelection()
    func goToStudyObjectiveSelection()
    func goToRegistration()
    func goToLogin(email: String?, password: String?)
    func goToUrl(_ url: URL)
    func finish()
}

extension AuthenticationCoordinatorType {
    func goToLogin() {
        goToLogin(email: nil, password: nil)
    }
}

final class AuthenticationCoordinator: NSObject, AuthenticationCoordinatorType {
    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private let authorizationRepository: AuthorizationRepositoryType
    private weak var delegate: AuthenticationCoordinatorDelegate?

    init(_ navigationController: UINavigationController, authorizationRepository: AuthorizationRepositoryType = resolve(), delegate: AuthenticationCoordinatorDelegate?) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.authorizationRepository = authorizationRepository
        self.delegate = delegate

        super.init()

        navigationController.delegate = self
    }

    func start(animated: Bool) {
        let backgroundImage = Asset.welcomeScreenBackground.image
        let gradientImage = Asset.welcomeScreenBackgroundGradient.image

        let welcomePresenter = WelcomePresenter(authenticationCoordinator: self)
        let welcomeViewController = WelcomeViewController(presenter: welcomePresenter, localizations: L10n.Welcome.self, backgroundImage: backgroundImage, gradientImage: gradientImage)

        navigationController.pushViewController(welcomeViewController, animated: animated)
    }

    func stop(animated: Bool) {
        navigationController.dismissAndPopAll(animated: animated)
    }

    func goToUserStageSelection() {
        let userStagePesenter = RegistrationUserStagePresenter(coordinator: self, userStages: AppConfiguration.shared.availableUserStages)
        let userStageViewController = UserStageViewController(presenter: userStagePesenter)
        navigationController.pushViewController(userStageViewController, animated: true)
    }

    func goToPurposeSelection() {
        let usagePurposePresenter = UsagePurposePresenter(coordinator: self)
        let usagePurposeViewController = UsagePurposeViewController(presenter: usagePurposePresenter)
        navigationController.pushViewController(usagePurposeViewController, animated: true)
    }

    func goToStudyObjectiveSelection() {
        let studyObjectivePresenter = RegistrationStudyObjectivePresenter(coordinator: self)
        let studyObjectiveViewController = StudyObjectiveViewController(presenter: studyObjectivePresenter)
        navigationController.pushViewController(studyObjectiveViewController, animated: true)
    }

    func goToRegistration() {
        let registrationPresenter = RegistrationPresenter(coordinator: self)
        let registrationViewController = RegistrationViewController(presenter: registrationPresenter)
        navigationController.pushViewController(registrationViewController, animated: true)
    }

    func goToLogin(email: String?, password: String?) {
        let prefilledCredentials = (email, password)
        let loginPresenter = LoginPresenter(coordinator: self, prefilledCredentials: prefilledCredentials)
        let loginViewController = LoginViewController(presenter: loginPresenter)
        navigationController.pushViewController(loginViewController, animated: true)
    }

    func goToUrl(_ url: URL) {
        let webCoordinator = WebCoordinator(navigationController.navigationController, url: url, navigationType: .internal(modalPresentationStyle: .overCurrentContext))
        webCoordinator.start(animated: true)
    }

    func finish() {
        delegate?.loginCompleted()
    }
}

extension AuthenticationCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        .portrait
    }
 }
