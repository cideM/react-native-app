//
//  LoginPresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 23.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Networking
import Domain

protocol LoginPresenterType: AnyObject {
    var view: LoginViewType? { get set }

    var forgotPasswordUrl: URL { get }

    func validateCredentials(email: String?, password: String?)
    func didTapClearButton()
    func didTapPasswordToggleButton(isvisible: Bool)
    func didTapLoginButton(email: String, password: String)
    func didTapForgotPasswordButton()
}

final class LoginPresenter: LoginPresenterType {
    weak var view: LoginViewType? {
        didSet {
            trackingProvider.track(.loginScreenShown)

            if let prefilledCredentials = prefilledCredentials {
                view?.prefill(email: prefilledCredentials.email, password: prefilledCredentials.password)
                validateCredentials(email: prefilledCredentials.email, password: prefilledCredentials.password)
            }
        }
    }

    var forgotPasswordUrl: URL {
        configuration.webBaseURL.appendingPathComponent("/app2web/forgotPassword")
    }

    private let coordinator: AuthenticationCoordinatorType
    private let authenticationClient: AuthenticationClient
    private let authorizationRepository: AuthorizationRepositoryType
    private let userDefaultsStorage: Storage
    private let configuration: URLConfiguration
    private let trackingProvider: TrackingType
    private let prefilledCredentials: (email: String?, password: String?)?
    private let analyticsTracking: TrackingType

    init(coordinator: AuthenticationCoordinatorType,
         authenticationClient: AuthenticationClient = resolve(),
         authorizationRepository: AuthorizationRepositoryType = resolve(),
         userDefaultsStorage: Storage = resolve(tag: .default),
         configuration: Configuration = AppConfiguration.shared,
         trackingProvider: TrackingType = resolve(),
         prefilledCredentials: (email: String?, password: String?)?,
         analyticsTracking: TrackingType = resolve()) {

        self.coordinator = coordinator
        self.authenticationClient = authenticationClient
        self.authorizationRepository = authorizationRepository
        self.userDefaultsStorage = userDefaultsStorage
        self.configuration = configuration
        self.trackingProvider = trackingProvider
        self.prefilledCredentials = prefilledCredentials
        self.analyticsTracking = analyticsTracking
    }

    func validateCredentials(email: String?, password: String?) {
        guard
            let email = email,
            email.count >= 3,
            let password = password,
            !password.isEmpty else {
            view?.setLoginButtonIsEnabled(false)
            return
        }

        view?.setLoginButtonIsEnabled(true)
    }

    func didTapClearButton() {
        trackingProvider.track(.clearEmail(locatedOn: .login))
    }

    func didTapPasswordToggleButton(isvisible: Bool) {
        trackingProvider.track(.togglePasswordVisiblity(locatedOn: .login, status: isvisible ? .invisible : .visible))
    }

    func didTapLoginButton(email: String, password: String) {
        let email = email.trimmingCharacters(in: .whitespaces)
        view?.setIsLoading(true)
        trackingProvider.track(.loginInitiated(email: email))

        authenticationClient.login(username: email, password: password, deviceId: authorizationRepository.deviceId) { [weak self] result in
            guard let self = self else { return }

            self.view?.setIsLoading(false)

            switch result {
            case .success(let authorization):
                self.authorizationRepository.authorization = authorization

                let firstLoginWasTracked = self.userDefaultsStorage.get(for: StorageKey.firstLoginWasTracked) ?? false
                if firstLoginWasTracked {
                    self.trackingProvider.track(.loginCompleted(email: email))
                } else {
                    self.trackingProvider.track(.firstLoginCompleted(email: email))
                    self.userDefaultsStorage.store(true, for: StorageKey.firstLoginWasTracked)
                }

                self.coordinator.finish()
            case .failure(let error):
                self.trackingProvider.track(.loginFailed(errorMessage: error.body))
                self.view?.presentMessage(error)
            }
        }
    }

    func didTapForgotPasswordButton() {
        trackingProvider.track(.forgotPasswordClicked(locatedOn: .login))

        coordinator.goToUrl(forgotPasswordUrl)
    }
}
