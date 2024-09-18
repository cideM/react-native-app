//
//  ConvenienceInitialiser+Pharma.swift
//  Networking
//
//  Created by Elmar Tampe on 20.02.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation
import KnowledgeGraphQLEntities

extension DrugReference {
    init(from drug: PharmaCardQuery.Data.AmbossSubstance.Drug) {
        self.init(id: DrugIdentifier(value: drug.id),
                  name: drug.name,
                  vendor: drug.vendor,
                  atcLabel: drug.atcLabel,
                  prescriptions: drug.prescriptions.compactMap {
            guard let val = $0.value else { return nil }
            return Prescription(status: val)
                  },
                  applicationForms: drug.applicationForms.compactMap {
            guard let val = $0.value else { return nil }
            return ApplicationForm(pharmaApplicationForm: val)
                  },
                  pricesAndPackages: drug.priceAndPackageInfo.map {
                        PriceAndPackage(packageSize: PackageSize(from: $0.packageSize?.value),
                            amount: $0.amount,
                            unit: $0.unit,
                            pharmacyPrice: $0.pharmacyPrice,
                            recommendedRetailPrice: $0.recommendedRetailPrice)
                  })
    }
}

extension PharmaSection {
    init(from section: PharmaCardQuery.Data.PharmaDrug.Section) {
        self.init(title: section.title,
                  text: section.text,
                  position: section.position)
    }
}

extension PriceAndPackageSorting {
    public init(order: PackageSizeSortingOrder) {
        switch order {
        case .ascending: self = .ascending
        case .mixed: self = .mixed
        }
    }
}

extension ApplicationForm {
    init?(pharmaApplicationForm: PharmaApplicationForm) {
        switch pharmaApplicationForm {
        case .other: self = .other
        case .parenteral: self = .parenteral
        case .topical: self = .topical
        case .enteral: self = .enteral
        case .ophthalmic: self = .ophthalmic
        case .urogenital: self = .urogenital
        case .nasalSpray: self = .nasalSpray
        case .rectal: self = .rectal
        case .inhalation: self = .inhalation
        case .bronchial: self = .bronchial
        }
    }
}

extension Prescription {
    init?(status: PharmaPrescriptionStatus) {
        switch status {
        case .overTheCounter: self = .overTheCounter
        case .pharmacyOnly: self = .pharmacyOnly
        case .prescriptionOnly: self = .prescriptionOnly
        case .narcotic: self = .narcotic
        }
    }
}

extension PackageSize {
    init?(from packageSize: NormedPackageSize?) {
        guard let packageSize = packageSize else { return nil }
        switch packageSize {
        case .n1: self = .n1
        case .n2: self = .n2
        case .n3: self = .n3
        case .ktp: self = .ktp
        case .notApplicable: self = .notApplicable
        }
    }
}
