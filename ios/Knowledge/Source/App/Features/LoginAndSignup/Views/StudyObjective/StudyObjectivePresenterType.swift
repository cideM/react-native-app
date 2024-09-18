//
//  StudyObjectivePresenterType.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 23.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain

protocol StudyObjectivePresenterType: AnyObject {
    var view: StudyObjectiveViewType? { get set }
    func selectedStudyObjectiveDidChange(studyObjective: StudyObjective)
    func getAvailableStudyObjectives()
    func bottomButtonTapped()
}
