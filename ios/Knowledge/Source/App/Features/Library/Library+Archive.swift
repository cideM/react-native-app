//  Library+Archive.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 09.11.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import ZIPFoundation
import ZippyJSON
import Foundation

extension Archive {

    private static let readQueue = DispatchQueue(label: "archive.access.queue")

    enum FileAccessError: Error {
        case noSuchFile
    }

    func object<T>(from entry: Entry?) throws -> T where T: Decodable {
        guard let entry = entry else {
            throw FileAccessError.noSuchFile
        }
        var fileData = Data()
        _ = try self.extract(entry, skipCRC32: true) { data in
            fileData.append(data)
        }

        #if targetEnvironment(simulator)
        let coder = JSONDecoder()
        #else
        let coder = ZippyJSONDecoder()
        #endif

        return try coder.decode(T.self, from: fileData)
    }

    func data(from entry: Entry?) throws -> Data {
        guard let entry = entry else {
            throw FileAccessError.noSuchFile
        }

        return try Self.readQueue.sync {
            var fileData = Data()
            _ = try self.extract(entry, skipCRC32: true) { data in
                fileData.append(data)
            }
            return fileData
        }
    }
}
