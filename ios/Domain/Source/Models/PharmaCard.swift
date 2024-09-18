//
//  PharmaCard.swift
//  Interfaces
//
//  Created by Manaf Alabd Alrahim on 18.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct PharmaCard {
    public let substance: Substance
    public let drug: Drug

    // sourcery: fixture:
    public init(substance: Substance, drug: Drug) {
        self.substance = substance
        self.drug = drug
    }
}
