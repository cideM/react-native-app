//
//  SettingsStudyObjectivePresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 16.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

final class SettingsStudyObjectivePresenter: StudyObjectivePresenterType {

    private let repository: StudyObjectiveRepositoryType
    private var selectedStudyObjective: StudyObjective?
    weak var view: StudyObjectiveViewType? {
        didSet {
            getAvailableStudyObjectives()
            view?.setBottomButtonTitle(L10n.Generic.save.uppercased())
        }
    }

    init(repository: StudyObjectiveRepositoryType) {
        self.repository = repository
    }

    func getAvailableStudyObjectives() {
        view?.setIsSyncing(true)

        repository.getStudyObjectives { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let studyObjectives):
                self.view?.setStudyObjectives(studyObjectives)
                self.setCurrentStudyObjectiveToTheView()
            case .failure(let error):
                self.view?.presentStudyObjectiveSubviewError(error)
            }

            self.view?.setIsSyncing(false)
        }
    }

    func selectedStudyObjectiveDidChange(studyObjective: StudyObjective) {
        guard selectedStudyObjective != studyObjective else { return }

        self.selectedStudyObjective = studyObjective
        view?.setBottomButtonIsEnabled(true)
    }

    private func setCurrentStudyObjectiveToTheView() {
        repository.getStudyObjective { [view] result in
            if case let .success(resultStudyObjective) = result, let studyObjective = resultStudyObjective {
                self.selectedStudyObjective = studyObjective
                view?.setCurrentStudyObjective(withId: studyObjective.eid)
            }
        }
    }

    func bottomButtonTapped() {
        guard let studyObjective = selectedStudyObjective else { return }

        view?.setIsSyncing(true)
        repository.setStudyObjective(studyObjective) { [view] result in
            view?.setIsSyncing(false)
            if case let .failure(error) = result {
                view?.presentStudyObjectiveAlertError(error)
            }
        }
    }
}
