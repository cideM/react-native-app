//
//  SegmentTrackingSerializer+Monograph.swift
//  Knowledge
//
//  Created by Silvio Bulla on 04.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {

    func name(for event: Tracker.Event.Monograph) -> String? {
        switch event {
        case .genericEvent(let eventName, _, _): return eventName
        case .monographOpened: return "pharma_monograph_opened"
        case .monographClosed: return "pharma_monograph_closed"
        case .monographFeedbackDismissed: return "pharma_monograph_feedback_dismissed"
        case .monographFeedbackSubmitted: return "pharma_monograph_feedback_submitted"
        case .pharmaAnchorLinkClicked: return "pharma_anchorlink_clicked"
        }
    }

    func parameters(for event: Tracker.Event.Monograph) -> [String: Any]? {
        let parameters = SegmentParameter.Container<SegmentParameter.Monograph>()

        switch event {
        case .genericEvent(_, let properties,
                           let databaseType):
            properties.forEach { key, value in parameters.set(value, for: key) }
            parameters.set(databaseType, for: .databaseType)

        case .monographOpened(monographTitle: let monographTitle,
                              monographId: let monographId,
                              databaseType: let databaseType):
            parameters.set(monographTitle, for: .monographTitle)
            parameters.set(monographId, for: .monographId)
            parameters.set(databaseType, for: .databaseType)

        case .monographClosed(monographTitle: let monographTitle,
                              monographId: let monographId,
                              viewingDurationSeconds: let viewingDurationSeconds,
                              databaseType: let databaseType):
            parameters.set(monographTitle, for: .monographTitle)
            parameters.set(monographId, for: .monographId)
            parameters.set(viewingDurationSeconds, for: .viewingDurationSeconds)
            parameters.set(databaseType, for: .databaseType)

        case .monographFeedbackDismissed(monographTitle: let monographTitle,
                                         monographId: let monographId,
                                         databaseType: let databaseType):
            parameters.set(monographTitle, for: .monographTitle)
            parameters.set(monographId, for: .monographId)
            parameters.set(databaseType, for: .databaseType)

        case .monographFeedbackSubmitted(monographTitle: let monographTitle,
                                         monographId: let monographId,
                                         feedbackText: let feedbackText,
                                         databaseType: let databaseType):
            parameters.set(monographTitle, for: .monographTitle)
            parameters.set(monographId, for: .monographId)
            parameters.set(feedbackText, for: .feedbackText)
            parameters.set(databaseType, for: .databaseType)

        case .pharmaAnchorLinkClicked(let articleXID,
                                      let monographID,
                                      let snippetID):
            parameters.set(articleXID, for: .articleXId)
            parameters.set(monographID, for: .monographId)
            parameters.set(snippetID, for: .snippetId)
        }

        return parameters.data
    }
}

extension SegmentParameter {
    enum Monograph: String {
        case monographTitle = "monograph_title"
        case monographId = "monograph_id"
        case databaseType = "database_type"
        case viewingDurationSeconds = "viewing_duration_seconds"
        case feedbackText = "feedback_text"
        case url = "url"
        case snippetId = "snippet_id"
        case articleXId = "article_xid"
    }
}
