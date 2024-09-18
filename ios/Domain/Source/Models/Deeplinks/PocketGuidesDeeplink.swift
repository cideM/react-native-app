//
//  PocketGuidesDeeplink.swift
//  Domain
//
//  Created by Manaf Alabd Alrahim on 04.09.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct PocketGuidesDeeplink: Equatable {

    // sourcery: fixture:
    public init() {}

    public init?(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        self.init(urlComponents: urlComponents)
    }

    public init?(urlComponents: URLComponents) {
        switch urlComponents.pathComponents {
        // /us/pocket-guides
        // /de/pocket-guides
        case [.oneOf(["de", "us"]), "pocket-guides"]:
            self.init()
        default: return nil
        }
    }
}
