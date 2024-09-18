//
//  SearchFilterViewItem.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 26.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

class SearchFilterViewItem {
    let name: String
    let value: String
    let count: Int
    var isActive: Bool
    let tapClosure: (SearchFilterViewItem) -> Void

    init(name: String, value: String, count: Int, isActive: Bool, tapClosure: @escaping (SearchFilterViewItem) -> Void) {
        self.name = name
        self.value = value
        self.count = count
        self.isActive = isActive
        self.tapClosure = tapClosure
    }
}
