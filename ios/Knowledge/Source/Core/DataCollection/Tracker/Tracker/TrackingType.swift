//
//  TrackingProvider.swift
//  Knowledge
//
//  Created by AMBOSS  VSS on 11.04.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain

// Will be refactored into a protocol later on when we flattened the events into entities again.
typealias Event = Tracker.Event
typealias UserTraits = Tracker.UserTraits

/// @mockable
protocol TrackingType {
    func set(_ userTraits: [UserTraits])
    func track(_ event: Event)
    func update(_ userTraits: UserTraits)
}
