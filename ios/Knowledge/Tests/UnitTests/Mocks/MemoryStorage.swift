//
//  MemoryStorage.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 10/1/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE

final class MemoryStorage: Storage {

    private(set) var storage: [String: Any] = [:]

    func store<T: Codable>(_ value: T?, for key: String) {
        storage[key] = value
    }

    func get<T: Codable>(for key: String) -> T? {
        storage[key] as? T
    }
}
