//
//  AppConfiguration+Features.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 20.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

extension AppConfiguration: FeatureConfiguration {

    var hasStudyObjective: Bool {
        switch appVariant {
        case .wissen: return false
        case .knowledge: return true
        }
    }

    var availableUserStages: [UserStage] {
        switch appVariant {
        case .wissen: return [ .preclinic, .clinic, .physician ]
        case .knowledge: return [.clinic, .physician]
        }
    }

    var searchActivityType: String {
        switch appVariant {
        case .wissen: return "de.miamed.AMBOSS-Bibliothek.search-user-activity"
        case .knowledge: return "us.miamed.amboss-knowledge.searchUserActivity"
        }
    }
}
