//
//  SegmentParameter.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 30.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

enum SegmentParameter {}

extension SegmentParameter {
    class Container<Key: RawRepresentable> where Key.RawValue == String {
        private(set) var data: [String: Any] = [:]

        func set(_ int: Int?, for key: Key) {
            guard let int = int else { return }
            data[key.rawValue] = int
        }

        func set(_ float: Float?, for key: Key) {
            guard let float = float else { return }
            data[key.rawValue] = float
        }

        func set(_ string: String?, for key: Key) {
            guard let string = string else { return }
            data[key.rawValue] = string
        }

        func set(_ bool: Bool?, for key: Key) {
            guard let bool = bool else { return }
            data[key.rawValue] = bool
        }

        func set(_ timeInterval: TimeInterval?, for key: Key) {
            guard let timeInterval = timeInterval else { return }
            set(Int(timeInterval * 1000), for: key)
        }

        func set(_ dictionary: [String: Any]?, for key: Key) {
            guard let dictionary = dictionary else { return }
            data[key.rawValue] = dictionary
        }

        func set(_ array: [Any]?, for key: Key) {
            guard let array = array else { return }
            data[key.rawValue] = array
        }

        func set<Value: RawRepresentable>(_ value: Value?, for key: Key) where Value.RawValue == String {
            set(value?.rawValue, for: key)
        }

        func set(_ error: Error?, for key: Key) {
            set(error?.localizedDescription, for: key)
        }
    }
}

extension SegmentParameter.Container {
    /// This is a "non value safe" extension of the container.
    /// It allows setting arbitrary keys and values which are not bound to any enum.
    /// This is used for "us monograph" tracking where we just forward an arbitrary
    /// tracking dictionary that is received from the web bridge
    func set(_ value: Any, for key: String) {
        data[key] = value
    }
}
