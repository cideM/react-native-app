//
//  RegistrationRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 23.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain

/*
 This repository is used to store the values a user selects in the different screens of the registration flow during registration.
 */

/// @mockable
protocol RegistrationRepositoryType: AnyObject {
    var userStage: UserStage? { get set }
    var usagePurpose: UsagePurpose? { get set }
    var studyObjective: StudyObjective? { get set }
}

final class RegistrationRepository: RegistrationRepositoryType {
    var userStage: UserStage?
    var usagePurpose: UsagePurpose?
    var studyObjective: StudyObjective?
}
