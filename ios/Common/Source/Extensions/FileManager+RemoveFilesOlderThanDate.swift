//
//  FileManager+RemoveFilesOlderThanDate.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 08.04.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

public extension FileManager {
    func removeItems(at directory: URL, olderThan timeInterval: TimeInterval) throws {
        let tempFileContents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [URLResourceKey.creationDateKey], options: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants)
        let oldTempFiles = try tempFileContents.filter {
            guard let creationDate = try $0.resourceValues(forKeys: [.creationDateKey]).creationDate else { return false }
            return creationDate < Date().addingTimeInterval(-timeInterval)
        }
        for oldFile in oldTempFiles {
            try FileManager.default.removeItem(at: oldFile)
        }
    }
}
