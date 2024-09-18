//
//  KeychainStorage.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 12.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import KeychainAccess
import Foundation

final class KeychainStorage: Storage {
    private let keychain: Keychain

    init(serviceName: String? = nil, accessGroup: String? = nil) {
        if let serviceName = serviceName, let accessGroup = accessGroup {
            keychain = Keychain(service: serviceName, accessGroup: accessGroup)
        } else if let serviceName = serviceName {
            keychain = Keychain(service: serviceName)
        } else if let accessGroup = accessGroup {
            keychain = Keychain(accessGroup: accessGroup)
        } else {
            keychain = Keychain()
        }
    }

    func store<T: Codable>(_ value: T?, for key: String) {
        guard let value = value else {
            do {
                try keychain.remove(key)
            } catch {
                assertionFailure("Failed to remove value for \(key) with error: \(error)")
            }
            return
        }
        // Primitive Types (String, Int, ...) can't be JSON encoded, so we have to store them directly
        switch value {
        case let string as String:
            do {
                try keychain.set(string, key: key)
            } catch {
                assertionFailure("Failed to store \(value) for \(key) with error: \(error)")
            }
        default:
            do {
                let data = try JSONEncoder().encode(value)
                try keychain.set(data, key: key)
            } catch {
                assertionFailure("Failed to store \(value) for \(key) with error: \(error)")
            }
        }
    }

    func get<T: Codable>(for key: String) -> T? {
        // Primitive Types (String, Int, ...) can't be JSON encoded, so they are stored directly
        switch T.self {
        case is String.Type: return try? keychain.getString(key) as? T
        default:
            guard let data = try? keychain.getData(key) else { return nil }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                assertionFailure("Failed to decode \(data) to type \(T.self) with \(error)")
                return nil
            }
        }
    }
}
