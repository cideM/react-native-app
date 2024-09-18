//
//  DrugHeaderViewData.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 21.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization

struct PharmaDrugSectionViewData {
    let activeIngredient: NSAttributedString

    let title: NSAttributedString?
    let subtitle: NSAttributedString?

    let lastUpdatedDate: NSAttributedString?

    let activeIngredientGroupTitle: NSAttributedString?
    let activeIngredientGroupValue: NSAttributedString?

    let dosageFormsTitle: NSAttributedString?
    let dosageFormsValue: NSAttributedString?

    let prescriptionsTitle: NSAttributedString?
    let prescriptionsValue: NSAttributedString?

    let packageSizeTitle: NSAttributedString?
    let priceTitle: NSAttributedString?
    let pricesAndPackages: [PriceAndPackage]

    init(drug: Drug, dateFormatter: (String) -> String?) {

        self.activeIngredient = NSAttributedString(string: L10n.Drug.activeIngredientLabel, attributes: .attributes(style: .paragraphSmall))

        self.title = NSAttributedString(string: drug.name, attributes: .attributes(style: .h4))

        if let vendor = drug.vendor {
            self.subtitle = NSAttributedString(string: vendor, attributes: .attributes(style: .paragraphSmall, with: [.color(.textTertiary)]))
        } else {
            self.subtitle = nil
        }

        let labelAttributes: [NSAttributedString.Key: Any] = .attributes(style: .h6, with: [.color(.textTertiary)])
        let valueAttributes: [NSAttributedString.Key: Any] = .attributes(style: .paragraphSmall, with: [.color(.textPrimary)])

        activeIngredientGroupTitle = NSAttributedString(string: L10n.Substance.activeIngredientGroupLabel.uppercased(), attributes: labelAttributes)
        activeIngredientGroupValue = NSAttributedString(string: drug.atcLabel, attributes: valueAttributes)

        dosageFormsTitle = NSAttributedString(string: L10n.Substance.dosageFormsLabel.uppercased(), attributes: labelAttributes)
        dosageFormsValue = NSAttributedString(string: drug.dosageForm.joined(separator: ", "), attributes: valueAttributes)

        let prescriptions = drug.prescriptions
            .map { $0.description }
            .joined(separator: L10n.Substance.prescriptionSeparator)
        prescriptionsTitle = NSAttributedString(string: L10n.Substance.prescriptionsLabel.uppercased(), attributes: labelAttributes)
        prescriptionsValue = NSAttributedString(string: prescriptions, attributes: valueAttributes)

        if let publishedAt = drug.publishedAt, let lastUpdateData = dateFormatter(publishedAt) {
            self.lastUpdatedDate = NSAttributedString(
                string: L10n.Substance.lastUpdateLabel(lastUpdateData),
                attributes: .attributes(style: .paragraphSmall, with: [.color(.textTertiary)]))
        } else {
            lastUpdatedDate = nil
        }

        packageSizeTitle = NSAttributedString(string: L10n.Substance.packageSizeTitle.uppercased(), attributes: labelAttributes)
        priceTitle = NSAttributedString(string: L10n.Substance.packagePriceTitle.uppercased(), attributes: labelAttributes)
        pricesAndPackages = drug.pricesAndPackages
    }
}
