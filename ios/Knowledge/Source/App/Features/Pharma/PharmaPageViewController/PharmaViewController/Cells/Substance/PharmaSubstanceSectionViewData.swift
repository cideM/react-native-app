//
//  PharmaSubstanceSectionViewData.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 21.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization

struct PharmaSubstanceSectionViewData {
    let activeIngredient: NSAttributedString
    let title: NSAttributedString
    let commercialDrugsButtonTitle: String
    let canSwitchDrug: Bool

    init(substance: Substance, canSwitchDrug: Bool) {
        self.canSwitchDrug = canSwitchDrug
        self.activeIngredient = NSAttributedString(string: L10n.Substance.activeIngredientLabel, attributes: .attributes(style: .paragraphSmall))
        self.commercialDrugsButtonTitle = L10n.Substance.CommercialDrugsButton.title
        self.title = NSAttributedString(attributedString: NSAttributedString(string: substance.name, attributes: .attributes(style: .paragraphSmall)))
    }
}
