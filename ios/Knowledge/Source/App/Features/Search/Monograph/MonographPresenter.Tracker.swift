//
//  MonographPresenter.Tracker.swift
//  MonographPresenter.Tracker
//
//  Created by Silvio Bulla on 04.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

extension MonographPresenter {

    struct MonographData {
        let title: String
        let identifier: String
        var openedAt = Date()
        var sectionOpenedAt: [String: Date] = [:]
    }

    class Tracker {
        private let trackingProvider: TrackingType
        private var monographData: MonographData?

        init(trackingProvider: TrackingType = resolve()) {
            self.trackingProvider = trackingProvider
        }

        func fillMonographData(_ monographData: MonographPresenter.MonographData) {
            self.monographData = monographData
        }

        func timeSpent(openedAt: Date, closedAt: Date = Date()) -> Int {
            Int(closedAt.timeIntervalSince(openedAt).rounded(.up))
        }

        func trackArticleSelected(articleId: LearningCardIdentifier) {
            self.trackingProvider.track(.articleSelected(articleID: articleId.value, referrer: .pharmaCard))
        }
    }
}

extension MonographPresenter.Tracker {

    /// This function handles all the generic analytics event that needs to be sent.
    /// - Parameters:
    ///   - event: Analytics event name
    ///   - properties: Analytics event properties
    func trackGenericEvent(eventName: String, properties: [String: Any]) {
        self.trackingProvider.track(.genericEvent(eventName: eventName, properties: properties))
    }

    func trackMonographOpened() {
        monographData?.openedAt = Date()
        guard let monographData = monographData else { return }
        self.trackingProvider.track(.monographOpened(monographTitle: monographData.title,
                                                              monographId: monographData.identifier))
    }

    func trackMonographClosed() {
        guard let monographData = monographData else { return }
        self.trackingProvider.track(.monographClosed(monographTitle: monographData.title,
                                                              monographId: monographData.identifier,
                                                              viewingDurationSeconds: timeSpent(openedAt: monographData.openedAt)))
    }

    /// This event is not used being that `Zendesk` does not trigger an event when the feedback view is dismissed.
    func trackMonographFeedbackDismissed() {
        guard let monographData = monographData else { return }
        self.trackingProvider.track(.monographFeedbackDismissed(monographTitle: monographData.title,
                                                                         monographId: monographData.identifier))
    }

    func trackMonographFeedbackSubmitted(feedbackText: String) {
        guard let monographData = monographData else { return }
        self.trackingProvider.track(.monographFeedbackSubmitted(monographTitle: monographData.title,
                                                                         monographId: monographData.identifier,
                                                                         feedbackText: feedbackText))
    }
}
