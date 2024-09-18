//
//  Terms.swift
//  Domain
//
//  Created by Roberto Seidenberg on 23.04.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation

public typealias TermsIdentifier = Identifier<Void, String>

public struct Terms {

    public let id: TermsIdentifier
    public let html: String

    public init(id: TermsIdentifier, html: String) {
        self.id = id
        self.html = html
    }
}
