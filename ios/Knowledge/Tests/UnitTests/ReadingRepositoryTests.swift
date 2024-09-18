//
//  ReadingRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 09.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class ReadingRepositoryTests: XCTestCase {

    var storage: Storage!
    var repository: ReadingRepositoryType!

    override func setUp() {
        storage = MemoryStorage()
        repository = ReadingRepository(storage: storage)
    }

    func testThatTheReadingStarts() {
        let learningCard = LearningCardIdentifier.fixture()

        repository.startReading(for: learningCard)

        let readings: [LearningCardIdentifier: [LearningCardReading]]? = storage.get(for: .learningCardReadings)
        XCTAssertEqual(readings?[learningCard]?.count, 1)
    }

    func testThatTheReadingEnds() {
        let learningCard = LearningCardIdentifier.fixture()

        repository.startReading(for: learningCard)
       _ = repository.endReading(for: learningCard)

        let readings: [LearningCardIdentifier: [LearningCardReading]]? = storage.get(for: .learningCardReadings)
        XCTAssertEqual(readings?[learningCard]?.first { $0.closedAt == nil }, nil)
    }

    func testThatAllReadingsAreReturnedForASpecificLearningCard() {
        let learningCard = LearningCardIdentifier.fixture()

        repository.startReading(for: learningCard)
        _ = repository.endReading(for: learningCard)
        repository.startReading(for: learningCard)

        let readings: [LearningCardIdentifier: [LearningCardReading]]? = storage.get(for: .learningCardReadings)
        XCTAssertEqual(readings?[learningCard]?.count, 2)
    }

    func testThatReadingsThatNeedSynchronizationAreReturned() {
        let learningCard = LearningCardIdentifier.fixture()
        let learningCard1 = LearningCardIdentifier.fixture()

        repository.startReading(for: learningCard)
        _ = repository.endReading(for: learningCard)
        repository.startReading(for: learningCard1)

        XCTAssertEqual(repository.readingsToBeSynchronized().count, 1)
    }

    func testAllReadingsThatAreClosedAreRemoved() {
        let learningCard = LearningCardIdentifier.fixture()
        let learningCard1 = LearningCardIdentifier.fixture()

        repository.startReading(for: learningCard)
        _ = repository.endReading(for: learningCard)
        repository.startReading(for: learningCard1)

        repository.removeSynchronizedReadings()

        let readings: [LearningCardIdentifier: [LearningCardReading]]? = storage.get(for: .learningCardReadings)
        XCTAssertEqual(readings?.count, 1)
    }

    func testThatReadingKeysWithoutValueAreRemovedAfterCallingRemoveSynchronisedReadings() {
        let learningCard = LearningCardIdentifier.fixture()

        repository.startReading(for: learningCard)
        _ = repository.endReading(for: learningCard)

        repository.removeSynchronizedReadings()

        let readings: [LearningCardIdentifier: [LearningCardReading]]? = storage.get(for: .learningCardReadings)
        XCTAssertEqual(readings?[learningCard], nil)
    }

    func testThatWhenRemoveAllDataIsCalledAllReadingsAreRemoved() {
        let learningCard = LearningCardIdentifier.fixture()

        repository.startReading(for: learningCard)
        _ = repository.endReading(for: learningCard)

        repository.removeAllDataFromLocalStorage()

        let readings: [LearningCardIdentifier: [LearningCardReading]]? = storage.get(for: .learningCardReadings)
        XCTAssertEqual(readings, [:])
    }
}
