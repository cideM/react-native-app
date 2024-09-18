//
//  FileStorage.swift
//  Knowledge
//
//  Created by Silvio Bulla on 18.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

/// Responsible for storing files to a specific folder url.
final class FileStorage: Storage {

    /// The location of the storage where the files should be stored.
    private let baseUrl: URL
    private let fileManager = FileManager()
    @Inject private var monitor: Monitoring

    init(with baseUrl: URL) {
        self.baseUrl = baseUrl

        do {
            try fileManager.createDirectory(at: baseUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {
            monitor.error("Failed to create the `FileStorage` directory at url: \(baseUrl)", context: .none)
        }
    }

    func store<T: Codable>(_ value: T?, for key: String) {
        guard let value = value else {
            try? fileManager.removeItem(atPath: baseUrl.appendingPathComponent(key).path)
            return
        }
        let encodedValue = data(for: value)
        fileManager.createFile(atPath: baseUrl.appendingPathComponent(key).path, contents: encodedValue, attributes: nil)
    }

    func get<T: Codable>(for key: String) -> T? {
        guard let data = fileManager.contents(atPath: baseUrl.appendingPathComponent(key).path) else { return nil }
        return value(for: data)
    }

    private func data<T: Codable>(for value: T) -> Data? {
        let data: Data?
        switch value {
        case let string as String:
            data = string.data(using: .utf8)
        default: data = try? JSONEncoder().encode(value)
        }
        return data
    }

    private func value<T: Codable>(for data: Data) -> T? {
        if T.self == String.self {
            return String(bytes: data, encoding: .utf8) as? T
        } else {
            return try? JSONDecoder().decode(T.self, from: data)
        }
    }
}
