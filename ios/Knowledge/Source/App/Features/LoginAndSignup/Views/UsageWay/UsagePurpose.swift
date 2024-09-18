//
//  UsagePurpose.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 12.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Localization

enum UsagePurpose: CustomStringConvertible {
    case clinicalPractice
    case examPreparation

    var description: String {
        switch self {
        case .clinicalPractice: return L10n.UsagePurpose.clinicalPractice
        case .examPreparation: return L10n.UsagePurpose.examPreparation
        }
    }
}
