//
//  DashboardTracker.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 17.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

final class DashboardListTracker {
    private let trackingProvider: TrackingType

    init(trackingProvider: TrackingType = resolve()) {
        self.trackingProvider = trackingProvider
    }
}

extension DashboardListTracker: ListTrackingProvider {
    func track(learningCard identifier: LearningCardIdentifier, tag: Tag) {
        switch tag {
        case .opened:
            trackingProvider.track(.articleSelected(articleID: identifier.value, referrer: .dashboardRecentlyReadList))
        case .learned, .favorite:
            assertionFailure("Not available")
        }
    }
}
