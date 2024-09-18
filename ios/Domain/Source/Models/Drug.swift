//
//  Drug.swift
//  Interfaces
//
//  Created by Merve Kavaklioglu on 07.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct Drug {

    public let eid: DrugIdentifier
    public let name: String
    public let atcLabel: String
    public let prescriptions: [Prescription]
    public let dosageForm: [String]
    public let sections: [PharmaSection]
    public let patientPackageInsertUrl: String?
    public let prescribingInformationUrl: String?
    public let publishedAt: String?
    public let substanceID: SubstanceIdentifier
    public let vendor: String?
    public let pricesAndPackages: [PriceAndPackage]

    // sourcery: fixture:
    public init(eid: DrugIdentifier, substanceID: SubstanceIdentifier, name: String, atcLabel: String, vendor: String?, prescriptions: [Prescription], dosageForm: [String], sections: [PharmaSection], patientPackageInsertUrl: String?, prescribingInformationUrl: String?, publishedAt: String?, pricesAndPackages: [PriceAndPackage]) {
        self.eid = eid
        self.substanceID = substanceID
        self.name = name
        self.atcLabel = atcLabel
        self.vendor = vendor
        self.prescriptions = prescriptions
        self.dosageForm = dosageForm
        self.sections = sections
        self.patientPackageInsertUrl = patientPackageInsertUrl
        self.prescribingInformationUrl = prescribingInformationUrl
        self.publishedAt = publishedAt
        self.pricesAndPackages = pricesAndPackages
    }
}
