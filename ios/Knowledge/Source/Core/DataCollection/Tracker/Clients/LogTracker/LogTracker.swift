//
//  LogTracker.swift
//  Knowledge
//
//  Created by Elmar Tampe on 14.07.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

class LogTracker: TrackingType {

    @Inject var logger: Monitoring

    // MARK: - EventTrackingType Conformance
    func set(_ userTraits: [UserTraits]) {
        logger.debug("\(userTraits)", context: .tracking)
    }

    func track(_ event: Event) {
        logger.debug("\(event)", context: .tracking)
    }

    func update(_ userTraits: UserTraits) {
        logger.debug("\(userTraits)", context: .tracking)
    }
}
