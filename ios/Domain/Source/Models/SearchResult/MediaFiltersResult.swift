//
//  MediaFiltersResult.swift
//  Interfaces
//
//  Created by Manaf Alabd Alrahim on 02.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct MediaFiltersResult {
    public let filters: [MediaFilter]

    // sourcery: fixture:
    public init(filters: [MediaFilter]) {
        self.filters = filters
    }
}
