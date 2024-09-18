//
//  MonographDeeplink.swift
//  Interfaces
//
//  Created by Manaf Alabd Alrahim on 03.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct MonographDeeplink: Equatable {
    public let monograph: MonographIdentifier
    public let anchor: MonographAnchorIdentifier?
    public let query: String?

    // sourcery: fixture:
    public init(monograph: MonographIdentifier, anchor: MonographAnchorIdentifier? = nil) {
        self.monograph = monograph
        self.anchor = anchor
        self.query = nil
    }

    init(monograph: String, anchor: String?, query: String?) {
        self.monograph = MonographIdentifier(value: monograph)
        self.anchor = anchor.map { MonographAnchorIdentifier(value: $0) }
        self.query = query
    }

    public init?(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        self.init(urlComponents: urlComponents)
    }

    public init?(urlComponents: URLComponents) {
        switch (urlComponents.pathComponents, urlComponents.fragment) {
        // /us/pharma/:monograph#anchor
        case (["us", "pharma", .any], let anchor):
            self.init(monograph: urlComponents.pathComponents[2], anchor: anchor, query: urlComponents.query)
        default: return nil
        }
    }

}
