//
//  Collection+Safe.swift
//  Common
//
//  Created by Manaf Alabd Alrahim on 13.09.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index?) -> Element? {
        guard let index else { return nil }
        return indices.contains(index) ? self[index] : nil
    }
}
