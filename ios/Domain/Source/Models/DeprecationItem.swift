//
//  DeprecationItem.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 24.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct DeprecationItem: Equatable {
    public let minVersion: String
    public let maxVersion: String
    public let type: DeprecationType
    public let platform: Platform
    public let identifier: String
    public let url: URL?

    // sourcery: fixture:
    public init(minVersion: String, maxVersion: String, type: DeprecationType, platform: Platform, identifier: String, url: URL?) {
        self.minVersion = minVersion
        self.maxVersion = maxVersion
        self.type = type
        self.platform = platform
        self.identifier = identifier
        self.url = url
    }
}

public extension DeprecationItem {
    // sourcery: fixture:
    enum DeprecationType: String {
        case unsupported
        case unknown
    }

    // sourcery: fixture:
    enum Platform: String {
        case ios
        case android
        case unknown
    }
}
