//
//  FeedbackRepository.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 18.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

/// @mockable
protocol FeedbackRepositoryType: AnyObject {
    func addFeedback(_ feedback: SectionFeedback)
    func removeFeedback(_ feedback: SectionFeedback)
    func getFirstFeedback() -> SectionFeedback?

    func removeAllDataFromLocalStorage()
}

final class FeedbackRepository {
    private let storage: Storage
    private var sectionFeedback: [SectionFeedback] {
        get {
            storage.get(for: .sectionFeedbackItems) ?? []
        }
        set {
            let oldValue = sectionFeedback
            storage.store(newValue, for: .sectionFeedbackItems)
            NotificationCenter.default.post(FeedbacksDidChangeNotification(oldValue: oldValue, newValue: newValue), sender: self)
        }
    }

    init(storage: Storage) {
        self.storage = storage
    }
}

extension FeedbackRepository: FeedbackRepositoryType {

    func addFeedback(_ feedback: SectionFeedback) {
        sectionFeedback.append(feedback)
    }

    func removeFeedback(_ feedback: SectionFeedback) {
        sectionFeedback = sectionFeedback.filter { $0 != feedback }
    }

    func getFirstFeedback() -> SectionFeedback? {
        sectionFeedback.first
    }

    func removeAllDataFromLocalStorage() {
        sectionFeedback = []
    }
}
