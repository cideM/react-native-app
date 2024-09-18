//
//  ListTracker.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 17.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

final class ListTracker {
    private let trackingProvider: TrackingType

    init(trackingProvider: TrackingType = resolve()) {
        self.trackingProvider = trackingProvider
    }
}

extension ListTracker: ListTrackingProvider {
    func track(learningCard identifier: LearningCardIdentifier, tag: Tag) {
        var referrer: Tracker.Event.Article.Referrer
        switch tag {
        case .opened: referrer = .recentlyReadList
        case .learned: referrer = .learnedList
        case .favorite: referrer = .favoritesList
        }
        trackingProvider.track(.articleSelected(articleID: identifier.value, referrer: referrer))
    }
}
