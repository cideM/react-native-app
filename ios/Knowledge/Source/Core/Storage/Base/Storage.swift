//
//  Storage.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 10/1/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

/// A protocol that should be adopted by any storage provider we're going to use. Be it Memory Storage, User Defaults or any other technique.
 protocol Storage: AnyObject {

    /// Stores a value for a certain key in the storage.
    /// - Parameter value: The value to store.
    /// - Parameter key: The key to store the value for.
     /// 
     @available(iOS,
                deprecated: 16,
                message: "Please use the keyed version")

    func store<T: Codable>(_ value: T?, for key: String)

    /// Gets a value for a key.
    /// - Parameter key: The key to store the value for.
     @available(iOS,
                deprecated: 16,
                message: "Please use the keyed version")
    func get<T: Codable>(for key: String) -> T?
 }

 extension Storage {
    func store<T: Codable>(_ value: T?, for key: StorageKey) {
        store(value, for: key.description)
    }

    func get<T: Codable>(for key: StorageKey) -> T? {
        get(for: key.description)
    }
 }
