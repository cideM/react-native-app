//
//  MediaFilter.swift
//  Interfaces
//
//  Created by Manaf Alabd Alrahim on 17.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct MediaFilter {
    public let value: String
    public let label: String
    public let matchingCount: Int
    public let isActive: Bool

    public init(value: String, label: String, matchingCount: Int, isActive: Bool) {
        self.value = value
        self.label = label
        self.matchingCount = matchingCount
        self.isActive = isActive
    }
}
