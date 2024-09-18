//
//  WelcomePresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 23.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

protocol WelcomePresenterType: AnyObject {
    var view: WelcomeViewType? { get set }

    func viewDidAppear()
    func signupButtonTapped()
    func loginButtonTapped()
}

final class WelcomePresenter: WelcomePresenterType {
    weak var view: WelcomeViewType?

    private let authenticationCoordinator: AuthenticationCoordinatorType
    private let consentApplicationService: ConsentApplicationServiceType
    private let trackingProvider: TrackingType

    init(authenticationCoordinator: AuthenticationCoordinatorType, consentApplicationService: ConsentApplicationServiceType = resolve(), trackingProvider: TrackingType = resolve()) {
        self.authenticationCoordinator = authenticationCoordinator
        self.consentApplicationService = consentApplicationService
        self.trackingProvider = trackingProvider
    }

    func viewDidAppear() {
        consentApplicationService.showConsentDialogIfNeeded()
        trackingProvider.track(.welcomeScreenShown)
    }

    func signupButtonTapped() {
        trackingProvider.track(.signUpButtonClicked)
        authenticationCoordinator.goToUserStageSelection()
    }

    func loginButtonTapped() {
        trackingProvider.track(.loginButtonClicked)
        authenticationCoordinator.goToLogin()
    }
}
