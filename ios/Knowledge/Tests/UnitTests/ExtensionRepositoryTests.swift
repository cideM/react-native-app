//
//  ExtensionRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul-Hameed on 10/4/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class ExtensionRepositoryTests: XCTestCase {

    func testThatItAddsExtensionsForALearningcard() {
        let repository = ExtensionRepository(storage: MemoryStorage())
        let expectedExtension = Extension.fixture()

        repository.set(ext: expectedExtension)

        let fetchedExtension = repository.extensionForSection(expectedExtension.section)
        XCTAssertEqual(fetchedExtension, expectedExtension)
    }

    func testThatItCanAddMultipleExtensionsForALearningcard() {
        let repository = ExtensionRepository(storage: MemoryStorage())

        let section1 = LearningCardSectionIdentifier.fixture(value: "spec_1234567890123456789012345678")
        let section2 = LearningCardSectionIdentifier.fixture(value: "spec_2234567890123456789012345678")
        let section3 = LearningCardSectionIdentifier.fixture(value: "spec_3234567890123456789012345678")

        let ext1 = Extension.fixture(section: section1, note: "spec_note1")
        let ext2 = Extension.fixture(section: section2, note: "spec_note2")
        let ext3 = Extension.fixture(section: section3, note: "spec_note3")

        repository.set(ext: ext1)
        repository.set(ext: ext2)
        repository.set(ext: ext3)

        [ext1, ext2, ext3].forEach {
            let foundExtension = repository.extensionForSection($0.section)
            XCTAssertEqual(foundExtension, $0)
        }
    }

    func testThatAddingAnExtensionToTheSameSectionOfALearningcardOverridesTheOldOne() {
        let repository = ExtensionRepository(storage: MemoryStorage())

        let section = LearningCardSectionIdentifier.fixture()

        let ext1 = Extension.fixture(section: section, note: "spec_note1")
        let ext2 = Extension.fixture(section: section, note: "spec_note2")

        repository.set(ext: ext1)
        repository.set(ext: ext2)

        let fetchedExtension = repository.extensionForSection(section)
        XCTAssertEqual(fetchedExtension, ext2)
    }

    func testThatGettingExtensionsWhenNoExtensionsWereAddedDoesntFail() {
        let repository = ExtensionRepository(storage: MemoryStorage())

        let section = LearningCardSectionIdentifier.fixture()

        let fetchedExtension = repository.extensionForSection(section)
        XCTAssertNil(fetchedExtension)
    }
}
