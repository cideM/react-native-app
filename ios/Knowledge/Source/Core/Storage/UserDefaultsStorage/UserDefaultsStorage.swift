//
//  UserDefaultsStorage.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 07.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

final class UserDefaultsStorage: Storage {

    private let userDefaults: UserDefaults

    init(_ userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func store<T: Codable>(_ value: T?, for key: String) {
        guard let value = value else {
            return userDefaults.removeObject(forKey: key)
        }
        // Primitive Types (String, Int, ...) can't be JSON encoded, so we have to store them directly
        do {
            userDefaults.set(try JSONEncoder().encode(value), forKey: key)
        } catch let error {
            assertionFailure("Failed to store value: \(value) for key: \(key) in user defaults. Error: \(error)")
        }
    }

    func get<T: Codable>(for key: String) -> T? {
        guard let data = userDefaults.value(forKey: key) as? Data else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
