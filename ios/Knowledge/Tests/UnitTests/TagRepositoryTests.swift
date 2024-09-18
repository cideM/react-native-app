//
//  TagRepositoryTests.swift
//  KnowledgeTests
//
//  Created by CSH on 04.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class TagRepositoryTests: XCTestCase {

    func testThatItAddsTagsForALearningcard() {
        let repository = TagRepository(storage: MemoryStorage())
        let learningcard = LearningCardIdentifier(value: "spec__")

        repository.addTag(.favorite, for: learningcard)

        let tags = repository.tags(for: learningcard)
        XCTAssert(tags.contains(.favorite))
        XCTAssert(tags.count == 1)
    }

    func testThatItAddsTagsForALearningcardOnlyOnce() {
        let repository = TagRepository(storage: MemoryStorage())
        let learningcard = LearningCardIdentifier(value: "spec__")
        repository.addTag(.favorite, for: learningcard)

        repository.addTag(.favorite, for: learningcard)

        let tags = repository.tags(for: learningcard)
        XCTAssert(tags.contains(.favorite))
        XCTAssert(tags.count == 1)
    }

    func testThatItAddsMultipleTagsForALearningcard() {
        let repository = TagRepository(storage: MemoryStorage())
        let learningcard = LearningCardIdentifier(value: "spec__")

        repository.addTag(.favorite, for: learningcard)
        repository.addTag(.learned, for: learningcard)

        let tags = repository.tags(for: learningcard)
        XCTAssert(tags.contains(.favorite))
        XCTAssert(tags.contains(.learned))
        XCTAssert(tags.count == 2)
    }

    func testThatItRemovesTagsForALearningcard() {
        let repository = TagRepository(storage: MemoryStorage())
        let learningcard = LearningCardIdentifier(value: "spec__")
        repository.addTag(.favorite, for: learningcard)
        repository.addTag(.learned, for: learningcard)
        repository.removeTag(.favorite, for: learningcard)

        let tags = repository.tags(for: learningcard)

        XCTAssertFalse(tags.contains(.favorite))
        XCTAssert(tags.contains(.learned))
        XCTAssert(tags.count == 1)
    }

    func testThatItImportsTagsForALearningcardOnlyOnce() {
        let repository = TagRepository(storage: MemoryStorage())
        let learningcard = LearningCardIdentifier(value: "spec__")

        repository.addTags([
            .init(type: .favorite, active: true, updatedAt: Date(), learningCard: learningcard),
            .init(type: .favorite, active: true, updatedAt: Date(), learningCard: learningcard)
        ])

        let tags = repository.tags(for: learningcard)
        XCTAssert(tags.contains(.favorite))
        XCTAssert(tags.count == 1)

        repository.addTags([
            .init(type: .favorite, active: true, updatedAt: Date(), learningCard: learningcard),
        ])

        XCTAssert(tags.contains(.favorite))
        XCTAssert(tags.count == 1)
    }

    func testThatItImportsMultipleTagsForALearningcard() {
        let repository = TagRepository(storage: MemoryStorage())
        let learningcard = LearningCardIdentifier(value: "spec__")

        repository.addTags([
            .init(type: .favorite, active: true, updatedAt: Date(), learningCard: learningcard),
            .init(type: .learned, active: true, updatedAt: Date(), learningCard: learningcard)
        ])

        let tags = repository.tags(for: learningcard)
        XCTAssert(tags.contains(.favorite))
        XCTAssert(tags.contains(.learned))
        XCTAssert(tags.count == 2)
    }

    func testThatRemovingIfItWasntAddedDoesntFail() {
        let repository = TagRepository(storage: MemoryStorage())
        let learningcard = LearningCardIdentifier(value: "spec__")
        repository.removeTag(.favorite, for: learningcard)

        let tags = repository.tags(for: learningcard)

        XCTAssert(tags.count == 0)
    }

    func testThatTaggingsContainsAddedTags() {
        let startDate = Date()
        let repository = TagRepository(storage: MemoryStorage())
        let learningcard = LearningCardIdentifier(value: "spec__")
        repository.addTag(.favorite, for: learningcard)

        let taggings = repository.taggings(changedSince: startDate.addingTimeInterval(-1), tags: [.favorite])

        XCTAssert(taggings.count == 1)
        XCTAssert(taggings.first!.active == true)
        XCTAssert(taggings.first!.type == .favorite)
        XCTAssert(taggings.first!.learningCard == learningcard)
    }

    func testThatGettingTagsWhenNoTagsWereAddedDoesntFail() {
        let repository = TagRepository(storage: MemoryStorage())
        let learningcard = LearningCardIdentifier(value: "spec__")

        let tags = repository.tags(for: learningcard)

        XCTAssert(tags.count == 0)
    }

    func testThatTaggingsContainsRemovedTags() {
        let startDate = Date()
        let repository = TagRepository(storage: MemoryStorage())
        let learningcard = LearningCardIdentifier(value: "spec__")
        repository.addTag(.favorite, for: learningcard)
        repository.removeTag(.favorite, for: learningcard)

        let taggings = repository.taggings(changedSince: startDate.addingTimeInterval(-1), tags: [.favorite])

        XCTAssert(taggings.count == 1)
        XCTAssert(taggings.first!.active == false)
        XCTAssert(taggings.first!.type == .favorite)
        XCTAssert(taggings.first!.learningCard == learningcard)
    }

    func testThatTaggingsDoesntContainToOldTags() {
        let startDate = Date()
        let repository = TagRepository(storage: MemoryStorage())
        let learningcard = LearningCardIdentifier(value: "spec__")
        repository.addTag(.favorite, for: learningcard)

        let taggings = repository.taggings(changedSince: startDate.addingTimeInterval(1), tags: [.favorite])

        XCTAssert(taggings.count == 0)
    }

    func testThatHasTagValueIsCorrect() {
        let repository = TagRepository(storage: MemoryStorage())
        let learningcardIdentifier = LearningCardIdentifier.fixture()

        repository.addTag(.favorite, for: learningcardIdentifier)

        XCTAssertTrue(repository.hasTag(.favorite, for: learningcardIdentifier))
    }
}
