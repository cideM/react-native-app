//
//  ReadingRepository.swift
//  Knowledge DE
//
//  Created by Silvio Bulla on 07.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

/// @mockable
protocol ReadingRepositoryType {
    func startReading(for learningCard: LearningCardIdentifier)
    func endReading(for learningCard: LearningCardIdentifier) -> LearningCardReading?
    /// This method returns only the readings which are already closed.
    @discardableResult func readingsToBeSynchronized() -> [LearningCardReading]
    func removeSynchronizedReadings()
    func removeAllDataFromLocalStorage()
}

final class ReadingRepository: ReadingRepositoryType {

    private let storage: Storage
    private var readings: [LearningCardIdentifier: [LearningCardReading]] {
        get {
            storage.get(for: .learningCardReadings) ?? [:]
        }
        set {
            storage.store(newValue, for: .learningCardReadings)
        }
    }

    init(storage: Storage) {
        self.storage = storage
    }

    func startReading(for learningCard: LearningCardIdentifier) {
        guard let readingsForLearningCard = readings[learningCard] else {
            readings[learningCard] = [LearningCardReading(learningCard: learningCard, openedAt: Date())]
            return
        }
        readings[learningCard] = readingsForLearningCard + [LearningCardReading(learningCard: learningCard, openedAt: Date())]
    }

    @discardableResult func endReading(for learningCard: LearningCardIdentifier) -> LearningCardReading? {
        guard var reading = readings[learningCard]?.first(where: { $0.closedAt == nil }) else {
            assertionFailure("Trying to end a learning card reading that is not started")
            return nil
        }
        reading.closedAt = Date()
        readings[learningCard] = (readings[learningCard] ?? []).filter { $0.closedAt != nil } + [reading]
        return reading
    }

    func readingsToBeSynchronized() -> [LearningCardReading] {
        readings
            .flatMap { $0.value }
            .filter { $0.closedAt != nil }
    }

    func removeSynchronizedReadings() {
        for (key, value) in readings {
            readings[key] = value.filter { $0.closedAt == nil }
            if (readings[key]?.isEmpty) ?? false { readings[key] = nil }
        }
    }

    func removeAllDataFromLocalStorage() {
        readings = [:]
    }
}
