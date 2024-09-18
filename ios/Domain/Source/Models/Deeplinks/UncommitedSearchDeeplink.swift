//
//  UncommitedSearchDeeplink.swift
//  Domain
//
//  Created by Manaf Alabd Alrahim on 31.05.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

public struct UncommitedSearchDeeplink: Equatable {

    public let type: SearchType?
    public let initialQuery: String
    public let initialFilter: String?

    // sourcery: fixture:
    public init(type: SearchType?, initialQuery: String, initialFilter: String? = nil) {
        self.type = type
        self.initialQuery = initialQuery
        self.initialFilter = initialFilter
    }
}
