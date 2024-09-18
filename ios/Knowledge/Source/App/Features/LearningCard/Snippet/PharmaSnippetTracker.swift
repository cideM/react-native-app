//
//  PharmaSnippetTracker.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 21.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

final class PharmaSnippetTracker {
    private let trackingProvider: TrackingType

    init(trackingProvider: TrackingType = resolve()) {
        self.trackingProvider = trackingProvider
    }
}

extension PharmaSnippetTracker: SnippetTrackingProvider {
    func track(learningCard identifier: LearningCardIdentifier) {
        trackingProvider.track(.articleSelected(articleID: identifier.value, referrer: .pharmaCard))
    }
}
