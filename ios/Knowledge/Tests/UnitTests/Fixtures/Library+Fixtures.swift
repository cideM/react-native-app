//
//  Library+Fixtures.swift
//  KnowledgeTests
//
//  Created by CSH on 28.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation
@testable import Knowledge_DE

extension Library {
    enum Fixture {
        static func valid() throws -> Library {
            try Library(with: validArchive())
        }

        static func validArchive() throws -> URL {
            let fileUrl = Bundle.tests.url(forResource: "lcTestArchive.zip", withExtension: nil)!
            let temporaryFilename = UUID().uuidString
            let temporaryUrl = fixtureTempFolder.appendingPathComponent(temporaryFilename)

            try FileManager.default.copyItem(at: fileUrl, to: temporaryUrl)
            return temporaryUrl
        }

        static func notAFile() -> URL {
            let temporaryFilename = UUID().uuidString
            let temporaryUrl = fixtureTempFolder.appendingPathComponent(temporaryFilename)
            return temporaryUrl
        }

        static func notAZipFile() throws -> URL {
            let fileUrl = Bundle.tests.url(forResource: "LearningCardTreeItem/SingleFolderElement.json", withExtension: nil)!
            let temporaryFilename = UUID().uuidString
            let temporaryUrl = fixtureTempFolder.appendingPathComponent(temporaryFilename)

            try FileManager.default.copyItem(at: fileUrl, to: temporaryUrl)
            return temporaryUrl
        }

        static func invalidArchive() throws -> URL {
            let fileUrl = Bundle.tests.url(forResource: "LearningCardTreeItem/SingleLearningCardElement.zip", withExtension: nil)!
            let temporaryFilename = UUID().uuidString
            let temporaryUrl = fixtureTempFolder.appendingPathComponent(temporaryFilename)

            try FileManager.default.copyItem(at: fileUrl, to: temporaryUrl)
            return temporaryUrl
        }

        private static var fixtureTempFolder: URL {
            let folder = FileManager.default.temporaryDirectory.appendingPathComponent("library-fixtures")
            try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            return folder
        }
    }
}
