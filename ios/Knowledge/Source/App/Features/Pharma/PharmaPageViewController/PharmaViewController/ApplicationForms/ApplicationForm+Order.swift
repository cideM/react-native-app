//
//  ApplicationForm+Order.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 23.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain

extension ApplicationForm {
    var order: Int {
        switch self {
        case .all: return 0
        case .enteral: return 1
        case .parenteral: return 2
        case .topical: return 3
        case .ophthalmic: return 4
        case .inhalation: return 5
        case .rectal: return 6
        case .nasalSpray: return 7
        case .urogenital: return 8
        case .bronchial: return 9
        case .other: return 10
        }
    }
}
