//
//  JSONFileInstantiatable.swift
//  Interfaces
//
//  Created by CSH on 27.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public protocol JSONFileInstantiatable {
    static func objectFromFile(_ url: URL) throws -> Self
    static func arrayFromFile(_ url: URL) throws -> [Self]
    func writeToFile(_ url: URL) throws

    /// This method takes an array of objects and writes the into separate files in a certain folder.
    /// - Parameters:
    ///   - objects: Objects to be written.
    ///   - folder: The folder to write the objects inside.
    ///   - filenameClosure: A closure to use to get a single file's name.
    static func write(_ objects: [Self], toFolder folder: URL, filenameClosure: (Self) -> String) throws
}

public extension JSONFileInstantiatable where Self: Encodable {
    func writeToFile(_ url: URL) throws {
        let encoder = JSONEncoder()
        let fileData = try encoder.encode(self)
        return try fileData.write(to: url)
    }
    static func write(_ objects: [Self], toFolder folder: URL, filenameClosure: (Self) -> String) throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        for object in objects {
            let url = folder.appendingPathComponent(filenameClosure(object))
            do {
                try object.writeToFile(url)
            } catch {
                #if targetEnvironment(simulator)
                // The simulator file system is case insensitive, but our files are case sensitive
                // we just want to ignore these errors, since they are not the real issue
                if !nearlySimilarFileExists(for: url) {
                    throw error
                }
                #else
                    throw error
                #endif
            }
        }
    }

    #if targetEnvironment(simulator)
    private static func nearlySimilarFileExists(for url: URL) -> Bool {
        do {
            let filenames = try FileManager.default.contentsOfDirectory(atPath: url.deletingLastPathComponent().path)
                .map { $0.lowercased() }
            return filenames.contains(url.lastPathComponent.lowercased())
        } catch {
            return false
        }
    }
    #endif
}
