//
//  Tracker.Event.Monograph.swift
//  Tracker.Event.Monograph
//
//  Created by Silvio Bulla on 30.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain

extension Tracker.Event {

    enum Monograph {
        case genericEvent(eventName: String,
                          properties: [String: Any],
                          databaseType: DatabaseType = .online)

        case monographOpened(monographTitle: String,
                             monographId: String,
                             databaseType: DatabaseType = .online)

        case monographClosed(monographTitle: String,
                             monographId: String,
                             viewingDurationSeconds: Int,
                             databaseType: DatabaseType = .online)

        case monographFeedbackDismissed(monographTitle: String,
                                        monographId: String,
                                        databaseType: DatabaseType = .online)

        case monographFeedbackSubmitted(monographTitle: String,
                                        monographId: String,
                                        feedbackText: String,
                                        databaseType: DatabaseType = .online)

        // This is part of an experiment that shows the monographs screen directly to US clinicians
        // (instead of the the phrasionary + pharma learning card combination)
        // when they tap on a medication name.
        // It's basically the same as tapping a pharma pill but without the popup before presenting the monograph
        // See here for more info: https://miamed.atlassian.net/browse/PHEX-1351
        case pharmaAnchorLinkClicked(articleXID: String, monographID: String, snippetID: String)
    }
}
