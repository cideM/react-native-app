//
//  Array+Helper.swift
//  Interfaces
//
//  Created by Cornelius Horstmann on 09.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

extension Array where Element == URLQueryItem {
    subscript(name: String) -> String? {
        first { $0.name == name }?.value
    }
}
