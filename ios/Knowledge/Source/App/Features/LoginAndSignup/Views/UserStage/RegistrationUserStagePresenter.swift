//
//  RegistrationUserStagePresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 23.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization
import UIKit

public final class RegistrationUserStagePresenter: UserStagePresenterType {

    private let coordinator: AuthenticationCoordinatorType
    private let userStageRepository: UserStageRepositoryType
    private let registrationRepository: RegistrationRepositoryType
    private let userStages: [UserStage]
    private let trackingProvider: TrackingType
    private let configuration: Configuration
    private var selectedUserStage: UserStage?

    init(coordinator: AuthenticationCoordinatorType, userStageRepository: UserStageRepositoryType = TemporaryUserStageRepository(), registrationRepository: RegistrationRepositoryType = resolve(), userStages: [UserStage], trackingProvider: TrackingType = resolve(), configuration: Configuration = AppConfiguration.shared) {
        self.coordinator = coordinator
        self.userStageRepository = userStageRepository
        self.registrationRepository = registrationRepository
        self.userStages = userStages
        self.trackingProvider = trackingProvider
        self.configuration = configuration
    }

    public weak var view: UserStageViewType? {
        didSet {
            let items = userStages.map { stage -> UserStageViewData.Item in
                switch stage {
                case .physician: UserStageViewData.Item(stage: .physician, title: L10n.UserStage.UserStagePhysician.title)
                case .clinic: UserStageViewData.Item(stage: .clinic, title: L10n.UserStage.UserStageClinic.title)
                case .preclinic: UserStageViewData.Item(stage: .preclinic, title: L10n.UserStage.UserStagePreclinic.title)
                }
            }
            view?.setViewData(UserStageViewData(items: items, discalimerState: .onlyButtonShown(buttonTitle: L10n.Generic.next)))
            trackingProvider.track(.userStageSelectionShown(referer: .signup))
        }
    }

    public func didSelectUserStage(_ userStage: UserStage) {
        guard selectedUserStage != userStage else { return }

        selectedUserStage = userStage
        let visibility = UserStageViewData.DisclaimerState.shown(disclaimer: userStage.agreementMessage, buttonTitle: L10n.Generic.next)
        view?.setDisclaimer(visibility) {}

        switch userStage {
        case .clinic:
            trackingProvider.track(.userStageSelected(stage: .clinic, referer: .signup))
        case .preclinic:
            trackingProvider.track(.userStageSelected(stage: .preclinic, referer: .signup))
        case .physician:
            trackingProvider.track(.userStageSelected(stage: .physician, referer: .signup))
        }
    }

    deinit {
        registrationRepository.userStage = nil
    }
}

extension RegistrationUserStagePresenter {

    public func agreementTapped(url: URL) {
        coordinator.goToUrl(url)
    }

    public func primaryButtonTapped() {
        guard let selectedUserStage = selectedUserStage else { return }

        view?.setIsLoading(true)
        userStageRepository.setUserStage(selectedUserStage) { [weak self] result in
            guard let self = self else { return }

            self.view?.setIsLoading(false)

            switch result {
            case .success:
                switch selectedUserStage {
                case .clinic: self.trackingProvider.track(.userStageSubmitted(stage: .clinic, referer: .signup))
                case .preclinic: self.trackingProvider.track(.userStageSubmitted(stage: .preclinic, referer: .signup))
                case .physician: self.trackingProvider.track(.userStageSubmitted(stage: .physician, referer: .signup))
                }

                self.registrationRepository.userStage = selectedUserStage

                if self.configuration.hasStudyObjective {
                    if selectedUserStage == .clinic {
                        self.coordinator.goToStudyObjectiveSelection()
                    } else {
                        self.coordinator.goToPurposeSelection()
                    }
                } else {
                    self.coordinator.goToRegistration()
                }
            case .failure(let userStageError):
                self.view?.presentMessage(userStageError)
            }
        }
    }
}
