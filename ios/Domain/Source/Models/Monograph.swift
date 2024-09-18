//
//  Monograph.swift
//  Interfaces
//
//  Created by Roberto Seidenberg on 07.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public typealias MonographIdentifier = Identifier<Monograph, String>
public typealias MonographAnchorIdentifier = Identifier<Monograph, String>

public struct Monograph {
    public let id: MonographIdentifier
    public let title: String
    public let classification: MonographClassification
    public let generic: Bool
    public let publishedAt: String
    public let html: String

    // sourcery: fixture:
    public init(id: MonographIdentifier, title: String, classification: MonographClassification, generic: Bool, publishedAt: String, html: String) {
        self.id = id
        self.title = title
        self.classification = classification
        self.generic = generic
        self.publishedAt = publishedAt
        self.html = html
    }
}

public struct MonographClassification {

    public let ahfsCode: String
    public let ahfsTitle: String
    public let atcCode: String
    public let atcTitle: String

    // sourcery: fixture:
    public init(ahfsCode: String, ahfsTitle: String, atcCode: String, atcTitle: String) {
        self.ahfsCode = ahfsCode
        self.ahfsTitle = ahfsTitle
        self.atcCode = atcCode
        self.atcTitle = atcTitle
    }
}
