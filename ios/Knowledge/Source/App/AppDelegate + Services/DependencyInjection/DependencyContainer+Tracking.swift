//
//  DependencyContainer+Tracking.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 27.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import DIKit

extension DependencyContainer {
    static let appReviewRepository = AppReviewRepository(storage: DependencyContainer.shared.resolve(tag: DIKitTag.Storage.default))
    static var tracking = module {
        single { GalleryAnalyticsTrackingProvider() as GalleryAnalyticsTrackingProviderType }
        single { CrashlyticsMonitor() }
        single { SegmentTracker() as SegmentTrackerType }
        single { CrashlyticsTracker() }
        single { BrazeTracker() }

        single { () -> TrackingType in
            let segmentTracker: SegmentTrackerType = shared.resolve()
            let brazeTracker: BrazeTracker = shared.resolve()
            var providers: [TrackingType] = [appReviewRepository, segmentTracker, brazeTracker]

            #if DEBUG || QA
            let logTracker = LogTracker()
            providers.append(logTracker)
            #else
            let crashlyticsTracker: CrashlyticsTracker = shared.resolve()
            providers.append(crashlyticsTracker)
            #endif

            let trackingProvider = Tracker(providers: providers)
            return trackingProvider as TrackingType
        }
    }
}
