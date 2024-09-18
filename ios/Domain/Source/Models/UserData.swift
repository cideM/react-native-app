//
//  UserData.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 18.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct UserData {
    public let featureFlags: [String]
    public let stage: UserStage?
    public let studyObjective: StudyObjective?
    public let shouldUpdateTermsAndConditions: Bool

    // sourcery: fixture:
    public init(
        featureFlags: [String],
        stage: UserStage?,
        studyObjective: StudyObjective?,
        shouldUpdateTermsAndConditions: Bool) {
        self.featureFlags = featureFlags
        self.stage = stage
        self.studyObjective = studyObjective
        self.shouldUpdateTermsAndConditions = shouldUpdateTermsAndConditions
    }
}
