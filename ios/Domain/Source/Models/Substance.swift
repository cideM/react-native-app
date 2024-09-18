//
//  Agent.swift
//  Interfaces
//
//  Created by Silvio Bulla on 19.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public typealias SubstanceIdentifier = Identifier<Substance, String>

public struct Substance {

    public let id: SubstanceIdentifier
    public let name: String
    public let drugReferences: [DrugReference]
    public let applicationForms: [ApplicationForm]
    public let pocketCard: PocketCard?
    public let basedOn: DrugIdentifier

    // sourcery: fixture:
    public init(id: SubstanceIdentifier, name: String, drugReferences: [DrugReference], pocketCard: PocketCard?, basedOn: DrugIdentifier) {
        self.id = id
        self.name = name
        self.drugReferences = drugReferences
        self.applicationForms = Array(Set(drugReferences.flatMap { $0.applicationForms })) // The application forms of an agent are derived from the application forms of its drugs.
        self.pocketCard = pocketCard
        self.basedOn = basedOn
    }
}
