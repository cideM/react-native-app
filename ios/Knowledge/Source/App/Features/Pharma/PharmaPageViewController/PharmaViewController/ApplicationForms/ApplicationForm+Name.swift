//
//  ApplicationForm+Name.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 22.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

extension ApplicationForm {
    var name: String {
        switch self {
        case .all: return L10n.Substance.ApplicationForms.All.title
        case .enteral: return L10n.Substance.ApplicationForms.Enteral.title
        case .parenteral: return L10n.Substance.ApplicationForms.Parenteral.title
        case .topical: return L10n.Substance.ApplicationForms.Topical.title
        case .ophthalmic: return L10n.Substance.ApplicationForms.Ophthalmic.title
        case .inhalation: return L10n.Substance.ApplicationForms.Inhalation.title
        case .rectal: return L10n.Substance.ApplicationForms.Rectal.title
        case .nasalSpray: return L10n.Substance.ApplicationForms.NasalSpray.title
        case .urogenital: return L10n.Substance.ApplicationForms.Urogenital.title
        case .bronchial: return L10n.Substance.ApplicationForms.Bronchial.title
        case .other: return L10n.Substance.ApplicationForms.Other.title
        }
    }
}
