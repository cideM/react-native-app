//
//  JSONFileInstantiatableTests.swift
//  InterfacesTests
//
//  Created by Merve Kavaklioglu on 04.11.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Domain
import XCTest

class JSONFileInstantiatableTests: XCTestCase {

    func testThatTwoSimilarFilesNotGeneratesErrorOnSimulator() {

        #if !targetEnvironment(simulator)
            return
        #endif

        // Given
        var learningCardMetaItems = [LearningCardMetaItem]()

        guard let nameOftheFirstFile = Identifier<(), String>("SAME") else { return }
        guard let nameOftheSecondFile = Identifier<(), String>("sAme") else { return }

        let metaItem1 = LearningCardMetaItem(title: "", urlPath: "", preclinicFocusAvailable: true, alwaysFree: true, minimapNodes: Array(), learningCardIdentifier: nameOftheFirstFile, galleries: Array(), questions: Array())
        let metaItem2 = LearningCardMetaItem(title: "", urlPath: "", preclinicFocusAvailable: true, alwaysFree: true, minimapNodes: Array(), learningCardIdentifier: nameOftheSecondFile, galleries: Array(), questions: Array())

        learningCardMetaItems.append(metaItem1)
        learningCardMetaItems.append(metaItem2)

        // When

        let tempFolder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        do {
            try LearningCardMetaItem.write(learningCardMetaItems, toFolder: tempFolder) { "\($0.learningCardIdentifier).json" }
        } catch {
            // Then
            XCTFail("The simulator shouldn't throw an error")
        }
    }
 }

// swiftlint is hard to silence here, hence "disable all"
// swiftlint:disable all
extension LearningCardMetaItem: JSONFileInstantiatable {

    public static func objectFromFile(_ url: URL) throws -> Self {
        fatalError("This method is here to satisfy the compiler for this test file. It should never be called")
    }

    public static func arrayFromFile(_ url: URL) throws -> [Self] {
        fatalError("This method is here to satisfy the compiler for this test file. It should never be called")
    }
}
// swiftlint:enable all
