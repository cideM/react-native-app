//
//  UserDefaults+KeyValueInspectable.swift
//  DeveloperOverlay
//
//  Created by CSH on 02.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

extension UserDefaults {

    public func inspectableSection(for keys: [String]? = nil, title: String = "UserDefaults") -> KeyValueSection {
        let keys = (keys ?? applicationKeys).sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }

        let items: [KeyValueItem] = keys.compactMap { key in
            guard let value = object(forKey: key) else { return nil }
            if let editableValue = inspectableValue(for: key, value: value) {
                return KeyValueItem(key: key, value: editableValue)
            } else {
                return KeyValueItem(key: key, value: "\(value)")
            }
        }

        return KeyValueSection(title: title, items: items)
    }

    private func inspectableValue(for key: String, value: Any) -> EditableValue? {
        switch value {
        case is Bool:
            return .bool({ [weak self] in self?.bool(forKey: key) }) { [weak self] in self?.set($0, forKey: key) }

        case is String:
            return .string({ [weak self] in self?.string(forKey: key) }) { [weak self] in self?.set($0, forKey: key) }

        case is Int:
            return .int({ [weak self] in self?.integer(forKey: key) }) { [weak self] in self?.set($0, forKey: key) }

        case is Data:
            guard let data = value as? Data else { return nil }

            // WORKAROUND:
            // We're storing everything in UserDefaults via Codable
            // This has the side effect that a "Date" and an "Int" decode equally fine
            // as each other cause a date is just a saved integer timestamp
            // In order to guess the right type for editing anyways
            // this crude pattern matching gets the job done ...
            if key.mightBeDate(), data.canBeDate() {
                return .date({ [weak self] in self?.date(forKey: key) }) { [weak self] in self?.setDate($0, forKey: key) }
            } else if key.mightBeInt(), data.canBeInt() {
                return .int({ [weak self] in self?.int(forKey: key) }) { [weak self] in self?.setInt($0, forKey: key) }
            } else {
                return nil
            }

        default:
            return nil
        }
    }

    private var applicationKeys: [String] {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return [] }
        return persistentDomain(forName: bundleIdentifier)?.keys.map { String($0) } ?? []
    }
}

fileprivate extension UserDefaults {

    private func setDate(_ date: Date, forKey key: String) {
        guard let data = try? JSONEncoder().encode(date) else { return }
        set(data, forKey: key)
    }

    private func date(forKey key: String) -> Date? {
        guard let object = object(forKey: key), let data = object as? Data else { return nil }
        return try? JSONDecoder().decode(Date.self, from: data)
    }

    private func setInt(_ int: Int, forKey key: String) {
        guard let data = try? JSONEncoder().encode(int) else { return }
        set(data, forKey: key)
    }

    private func int(forKey key: String) -> Int? {
        guard let object = object(forKey: key), let data = object as? Data else { return nil }
        return try? JSONDecoder().decode(Int.self, from: data)
    }
}

fileprivate extension Data {

    func canBeDate() -> Bool {
        (try? JSONDecoder().decode(Date.self, from: self)) != nil
    }

    func canBeInt() -> Bool {
        (try? JSONDecoder().decode(Int.self, from: self)) != nil
    }
}

fileprivate extension String {

    func mightBeDate() -> Bool {
        lowercased().contains("date")
    }

    func mightBeInt() -> Bool {
        lowercased().contains("count")
    }
}
