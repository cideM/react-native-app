//
//  RegistrationStudyObjectivePresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 23.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

final class RegistrationStudyObjectivePresenter: StudyObjectivePresenterType {

    weak var view: StudyObjectiveViewType? {
        didSet {
            getAvailableStudyObjectives()
            view?.setBottomButtonTitle(L10n.Generic.next.uppercased())
        }
    }

    private let coordinator: AuthenticationCoordinatorType
    private let studyObjectiveRepository: StudyObjectiveRepositoryType
    private let registrationRepository: RegistrationRepositoryType
    private var selectedStudyObjective: StudyObjective?

    init(coordinator: AuthenticationCoordinatorType, studyObjectiveRepository: StudyObjectiveRepositoryType = RegistrationStudyObjectiveRepository(), registrationRepository: RegistrationRepositoryType = resolve()) {
        self.coordinator = coordinator
        self.studyObjectiveRepository = studyObjectiveRepository
        self.registrationRepository = registrationRepository
    }

    func getAvailableStudyObjectives() {
        view?.setIsSyncing(true)

        studyObjectiveRepository.getStudyObjectives { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let studyObjectives):
                self.view?.setStudyObjectives(studyObjectives)
            case .failure(let error):
                self.view?.presentStudyObjectiveSubviewError(error)
            }

            self.view?.setIsSyncing(false)
        }
    }

    func selectedStudyObjectiveDidChange(studyObjective: StudyObjective) {
        guard selectedStudyObjective != studyObjective else { return }

        selectedStudyObjective = studyObjective
        view?.setBottomButtonIsEnabled(true)
    }

    func bottomButtonTapped() {
        guard selectedStudyObjective != nil else { return }

        registrationRepository.studyObjective = selectedStudyObjective
        coordinator.goToRegistration()
    }

    deinit {
        registrationRepository.studyObjective = nil
    }
}
