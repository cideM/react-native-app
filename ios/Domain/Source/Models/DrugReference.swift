//
//  DrugReference.swift
//  Interfaces
//
//  Created by Silvio Bulla on 19.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public typealias DrugIdentifier = Identifier<DrugReference, String>

public struct DrugReference {

    public let id: DrugIdentifier
    public let name: String
    public let vendor: String?
    public let atcLabel: String
    public let prescriptions: [Prescription]
    public let applicationForms: [ApplicationForm]
    public let pricesAndPackages: [PriceAndPackage]

    // sourcery: fixture:
    public init(id: DrugIdentifier,
                name: String,
                vendor: String?,
                atcLabel: String,
                prescriptions: [Prescription],
                applicationForms: [ApplicationForm],
                pricesAndPackages: [PriceAndPackage]) {
        self.id = id
        self.name = name
        self.vendor = vendor
        self.atcLabel = atcLabel
        self.prescriptions = prescriptions
        self.applicationForms = applicationForms
        self.pricesAndPackages = pricesAndPackages
    }
}
