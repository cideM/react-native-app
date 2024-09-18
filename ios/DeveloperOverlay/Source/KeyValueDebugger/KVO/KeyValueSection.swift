//
//  KeyValueSection.swift
//  DeveloperOverlay
//
//  Created by CSH on 24.06.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct KeyValueSection {
    public let title: String?
    public let items: [KeyValueItem]

    public init(title: String?, items: [KeyValueItem]) {
        self.title = title
        self.items = items
    }
}

public extension KeyValueSection {
    init(_ dictionary: [String: Any], title: String? = nil) {
        self.title = title
        let keys = dictionary.keys.sorted()
        self.items = keys.compactMap { key in
            guard let value = dictionary[key] else { return nil }
            return KeyValueItem(key: key, value: "\(value)")
        }
    }
}
