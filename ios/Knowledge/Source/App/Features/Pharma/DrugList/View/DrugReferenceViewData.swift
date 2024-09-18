//
//  DrugReferenceViewData.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 23.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct DrugReferenceViewData: Equatable {
    let id: DrugIdentifier
    let name: String
    let vendor: String
    let atc: String
    let applicationForms: String
    let priceAndPackageSize: String

    init(drugReference: DrugReference) {
        self.id = drugReference.id
        self.name = drugReference.name
        self.vendor = drugReference.vendor ?? ""
        self.atc = drugReference.atcLabel
        self.applicationForms = drugReference.applicationForms.compactMap { $0.name }.joined(separator: ", ")

        guard let firstPriceAndPackageSize = drugReference.pricesAndPackages.first else {
            priceAndPackageSize = ""
            return
        }

        self.priceAndPackageSize = firstPriceAndPackageSize.packageSizeDescription + (firstPriceAndPackageSize.priceDescription.isEmpty ? "" : ", ") + firstPriceAndPackageSize.priceDescription
    }
}
