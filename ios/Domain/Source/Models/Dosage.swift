//
//  Dosage.swift
//  Interfaces
//
//  Created by Roberto Seidenberg on 11.04.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation

public typealias DosageIdentifier = Identifier<Dosage, String>

public struct Dosage {

    public let id: DosageIdentifier
    public let html: String
    public let ambossSubstanceLink: AmbossSubstanceLink?

    public init(id: DosageIdentifier,
                html: String,
                ambossSubstanceLink: AmbossSubstanceLink?) {
        self.id = id
        self.html = html
        self.ambossSubstanceLink = ambossSubstanceLink
    }
}
