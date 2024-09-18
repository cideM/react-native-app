//
//  RegistrationPresenter.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 15.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Networking
import Localization

public protocol RegistrationPresenterType {
    var view: RegistrationViewType? { get set }

    func startButtonTapped(with email: String, password: String)
    func emailTextFieldRightButtonTapped()
    func passwordTextFieldRightButtonTapped(isVisible: Bool)
    func navigateToLogin(email: String?, password: String?)
}

public final class RegistrationPresenter: RegistrationPresenterType {
    public weak var view: RegistrationViewType? {
        didSet {
            if remoteConfigRepository.iap5DayTrialRemoved {
                view?.setButtonTitle(text: L10n.SignUp.startButtonTitleVariant)
            } else {
                view?.setButtonTitle(text: L10n.SignUp.startButtonTitle)
            }
        }
    }

    private let coordinator: AuthenticationCoordinatorType
    private let authenticationClient: AuthenticationClient
    private let authorizationRepository: AuthorizationRepositoryType
    private let registrationRepository: RegistrationRepositoryType
    private let appConfiguration: Configuration
    private var userDefaultsStorage: Storage
    private let analyticsTracking: TrackingType
    private let brazeClient: BrazeApplicationServiceType
    private let remoteConfigRepository: RemoteConfigRepositoryType

    @Inject private var monitor: Monitoring

    init(coordinator: AuthenticationCoordinatorType,
         authenticationClient: AuthenticationClient = resolve(),
         authorizationRepository: AuthorizationRepositoryType = resolve(),
         registrationRepository: RegistrationRepositoryType = resolve(),
         appConfiguration: Configuration = AppConfiguration.shared,
         userDefaultsStorage: Storage = resolve(tag: .default),
         analyticsTracking: TrackingType = resolve(),
         brazeClient: BrazeApplicationServiceType = resolve(),
         remoteConfigRepository: RemoteConfigRepositoryType = resolve()) {
        self.coordinator = coordinator
        self.authenticationClient = authenticationClient
        self.authorizationRepository = authorizationRepository
        self.registrationRepository = registrationRepository
        self.appConfiguration = appConfiguration
        self.userDefaultsStorage = userDefaultsStorage
        self.analyticsTracking = analyticsTracking
        self.brazeClient = brazeClient
        self.remoteConfigRepository = remoteConfigRepository
    }

    public func startButtonTapped(with email: String, password: String) {
        guard let stage = registrationRepository.userStage else { return }

        view?.setIsLoading(true)

        analyticsTracking.track(.emailSubmitted(email: email))
        analyticsTracking.track(.passwordSubmitted(email: email))

        let isGeneralStudyObjectiveSelected = registrationRepository.usagePurpose == .clinicalPractice

        let appCode: String
        switch AppConfiguration.shared.appVariant {
        case .wissen: appCode = "wissen"
        case .knowledge: appCode = "knowledge"
        }

        authenticationClient.signup(email: email,
                                    password: password,
                                    stage: stage,
                                    studyObjective: registrationRepository.studyObjective,
                                    isGeneralStudyObjectiveSelected: isGeneralStudyObjectiveSelected,
                                    appCode: appCode,
                                    skipEmailVerification: true,
                                    deviceId: authorizationRepository.deviceId) { [weak self] result  in
            guard let self = self else { return }

            self.view?.setIsLoading(false)

            switch result {
            case .success:
                self.view?.setIsLoading(true)

                self.analyticsTracking.track(.loginInitiated(email: email))
                self.authenticationClient.login(username: email,
                                                password: password,
                                                deviceId: self.authorizationRepository.deviceId) { [weak self] result in
                    guard let self = self else { return }

                    self.view?.setIsLoading(false)

                    switch result {
                    case .success(let authorization):
                        self.analyticsTracking.track(.firstLoginCompleted(email: email))
                        self.userDefaultsStorage.store(true, for: StorageKey.firstLoginWasTracked)
                        self.userDefaultsStorage.store(false, for: StorageKey.didPresentStoreAfterSignup)
                        self.authorizationRepository.authorization = authorization
                        self.trackRegistration(email: email, stage: stage) // Must be after authorization = authorization!
                        self.coordinator.finish()
                    case .failure(let error):
                        self.analyticsTracking.track(.loginFailed(errorMessage: error.body))
                        self.coordinator.goToLogin(email: email, password: password)
                    }
                }
            case .failure(let error):
                switch error {
                case .apiResponseError(let apiErrors) where apiErrors.contains(.emailAlreadyRegistered):
                    self.analyticsTracking.track(.signUpEmailAlreadyTaken(email: email))
                    self.view?.showEmailInformationLabel(text: L10n.SignUp.labelEmailInformationText)
                default:
                    self.view?.presentMessage(error)
                    self.monitor.error(error, context: .api)
                }
            }
        }
    }

    // MARK: - Coordination
    public func navigateToLogin(email: String?, password: String?) {
        coordinator.goToLogin(email: email, password: password)
    }

    // MARK: - Tracking

    public func emailTextFieldRightButtonTapped() {
        analyticsTracking.track(.clearEmail(locatedOn: .setEmail))
    }

    public func passwordTextFieldRightButtonTapped(isVisible: Bool) {
        analyticsTracking.track(.togglePasswordVisiblity(locatedOn: .setPassword, status: isVisible ? .visible : .invisible))
    }

    // MARK: - Braze
    private func trackRegistration(email: String, stage: UserStage) {
        let analyticsStage: Tracker.Event.SignupAndLogin.UserStage
        switch stage {
        case .physician: analyticsStage = .physician
        case .clinic: analyticsStage = .clinic
        case .preclinic: analyticsStage = .preclinic
        }

        let analyticsRegion: String
        switch appConfiguration.appVariant {
        case .wissen: analyticsRegion = "eu"
        case .knowledge: analyticsRegion = "us"
        }

        analyticsTracking.track(.registerSuccess(email: email, region: analyticsRegion, stage: analyticsStage))
    }
}
