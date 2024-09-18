//
//  BrazeApplicationService+Extension.swift
//  Knowledge
//
//  Created by Elmar Tampe on 22.06.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

extension BrazeApplicationService {

    static func map(userStage: Tracker.Event.SignupAndLogin.UserStage) -> BrazeStage {
        switch userStage {
        case .physician: return BrazeStage.physician
        case .clinic: return BrazeStage.clinic
        case .preclinic: return BrazeStage.preclinic
        }
    }

    static func map(variant: AppVariant) -> BrazeRegion {
        switch variant {
        case .knowledge: return .us
        case .wissen: return .de
        }
    }
}
