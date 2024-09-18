//
//  KeyValueItem.swift
//  DeveloperOverlay
//
//  Created by CSH on 24.06.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct KeyValueItem {
    let key: String
    let value: Value

    public init(key: String, value: String) {
        self.key = key
        self.value = .readonly(value)
    }

    public init(key: String, value: Any?) {
        self.key = key
        if let value = value {
            self.value = .readonly("\(value)")
        } else {
            self.value = .readonly("nil")
        }
    }

    public init(key: String, value: EditableValue) {
        self.key = key
        self.value = .editable(value)
    }
}

public extension KeyValueItem {

    init<T: AnyObject, V>(object: T, title: String, readonly keyPath: KeyPath<T, V>) {
        key = title
        let value = object[keyPath: keyPath]
        self.value = .readonly("\(value)")
    }

}

public enum EditableValue: CustomStringConvertible {
    case string(() -> String?, (String) -> Void)
    case bool(() -> Bool?, (Bool) -> Void)
    case int(() -> Int?, (Int) -> Void)
    case date(() -> Date?, (Date) -> Void)

    public var description: String {
        switch self {
        case .string(let string, _): return string() ?? "nil"
        case .bool(let bool, _): if let bool = bool() { return "\(bool)" } else { return "nil" }
        case .int(let int, _): if let int = int() { return "\(int)" } else { return "nil" }
        case .date(let date, _): if let date = date() { return "\(date)" } else { return "nil" }
        }
    }
}

public enum Value: CustomStringConvertible {
    case readonly(String)
    case editable(EditableValue)

    public var description: String {
        switch self {
        case .readonly(let string): return string
        case .editable(let editable):
            switch editable {
            case .string, .bool, .int:
                return editable.description
            case .date(let date, _):
                if let date = date() {
                    return ISO8601DateFormatter().string(from: date)
                } else {
                    return "nil"
                }
            }
        }
    }
}
