//
//  UsagePurposePresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 12.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

protocol UsagePurposePresenterType: AnyObject {
    var view: UsagePurposeViewType? { get set }

    func didSelectUsagePurpose(_ usagePurpose: UsagePurpose)
}

final class UsagePurposePresenter: UsagePurposePresenterType {
    weak var view: UsagePurposeViewType? {
        didSet {
            view?.setUsagePurposes([.clinicalPractice, .examPreparation])
        }
    }

    private let coordinator: AuthenticationCoordinatorType
    private let registrationRepository: RegistrationRepositoryType

    init(coordinator: AuthenticationCoordinatorType, registrationRepository: RegistrationRepositoryType = resolve()) {
        self.coordinator = coordinator
        self.registrationRepository = registrationRepository
    }

    func didSelectUsagePurpose(_ usagePurpose: UsagePurpose) {
        guard let selectedUserStage = registrationRepository.userStage else { return }

        registrationRepository.usagePurpose = usagePurpose

        switch (selectedUserStage, usagePurpose) {
        case (.physician, .examPreparation):
            coordinator.goToStudyObjectiveSelection()
        default:
            coordinator.goToRegistration()
        }
    }

    deinit {
        registrationRepository.usagePurpose = nil
    }
}
