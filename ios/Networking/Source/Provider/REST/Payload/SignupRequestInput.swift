//
//  SignupRequestInput.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 07.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation

struct SignupRequestInput {
    let email: String
    let password: String
    let stage: Stage?
    let studyObjective: String?
    let isGeneralStudyObjectiveSelected: Bool
    let appCode: String // This will be part of the deeplink created via the toggle above, in this case -> https://www.amboss.com/de/app/knowledge/login
    let skipEmailVerification: Bool
    let skipAccessChooser: Bool // This tells the backend to present a button with a link back to the iOS app at the end of the browser based email confirmation

    init(email: String,
         password: String,
         stage: Stage?,
         studyObjective: String?,
         isGeneralStudyObjectiveSelected: Bool,
         appCode: String,
         skipEmailVerification: Bool,
         skipAccessChooser: Bool) {
        self.email = email
        self.password = password
        self.stage = stage
        self.studyObjective = studyObjective
        self.isGeneralStudyObjectiveSelected = isGeneralStudyObjectiveSelected
        self.appCode = appCode
        self.skipEmailVerification = skipEmailVerification
        self.skipAccessChooser = skipAccessChooser
    }

    enum Stage: String, Encodable {
        case clinic = "stage_clinic"
        case preclinic = "stage_preclinic"
        case physician = "stage_physician"
        case none = ""
    }
}

extension SignupRequestInput: Encodable {
    enum CodingKeys: String, CodingKey {
        case email = "email_address"
        case password
        case stage
        case studyObjective = "study_objective_eid"
        case skipEmailVerification = "skip_email_verification"
        case skipAccessChooser = "skip_access_chooser"
        case appCode = "app_code"
        case isGeneralStudyObjectiveSelected = "is_general_studies_study_objective"
    }
}
