//
//  AccountSettingsPresenter.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 07.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

protocol AccountSettingsPresenterType {
    var view: AccountSettingsViewType? { get set }

    func logoutButtonTapped()
    func deleteAccountButtonTapped()
}

final class AccountSettingsPresenter: AccountSettingsPresenterType {
    private let coordinator: SettingsCoordinatorType
    private let authorizationRepository: AuthorizationRepositoryType
    private let learningCardClient: LearningCardLibraryClient
    private let authenticationClient: AuthenticationClient
    private let trackingProvider: TrackingType

    init(coordinator: SettingsCoordinatorType,
         authorizationRepository: AuthorizationRepositoryType,
         learningCardClient: LearningCardLibraryClient,
         authenticationClient: AuthenticationClient,
         trackingProvider: TrackingType = resolve()) {
        self.coordinator = coordinator
        self.authorizationRepository = authorizationRepository
        self.learningCardClient = learningCardClient
        self.authenticationClient = authenticationClient
        self.trackingProvider = trackingProvider
    }

    weak var view: AccountSettingsViewType? {
        didSet {
            view?.setEmail(authorizationRepository.authorization?.user.email ?? "")
            trackingProvider.track(.settingsAccountOpened)
        }
    }

    func logoutButtonTapped() {
        trackingProvider.track(.settingsLogoutClicked)

        let cancelAction = MessageAction(title: L10n.Generic.no, style: .primary) { [weak self] in
            self?.trackingProvider.track(.settingsLogoutCancelled)
            return true
        }

        let logoutAction = MessageAction(title: L10n.Generic.yes, style: .normal) { [weak self] in
            guard let self = self else { return true }

            self.trackingProvider.track(.settingsLogoutConfirmed)
            self.authenticationClient.logout(deviceId: self.authorizationRepository.deviceId) { _ in }
//            self.attributionTrackingApplicationService.reset()
            return true
        }

        view?.presentMessage(title: L10n.AccountSettings.Alert.title, message: L10n.AccountSettings.Alert.message, actions: [cancelAction, logoutAction])
    }

    func deleteAccountButtonTapped() {
        let okAction = MessageAction(title: L10n.Generic.alertDefaultButton, style: .primary) { [weak self] in
            self?.coordinator.goToAccountDeletion { [weak self] in
                self?.learningCardClient.getTaggings(after: nil) { [weak self] result in
                    switch result {
                    case .success: break
                    case .failure(let error):
                        if case .authTokenIsInvalid = error {
                            self?.authorizationRepository.accountWasDeleted = true
                        }
                    }
                }
            }

            return true
        }

        view?.presentMessage(title: L10n.AccountSettings.DeleteAccountAlert.title, message: L10n.AccountSettings.DeleteAccountAlert.message, actions: [okAction])
    }
}
