//
//  Tracker.swift
//  Knowledge
//
//  Created by AMBOSS  VSS on 11.04.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain

final class Tracker: TrackingType {

    let providers: [TrackingType]

    init(providers: [TrackingType]) {
        self.providers = providers
    }

    func set(_ userTraits: [UserTraits]) {
        for provider in providers {
            provider.set(userTraits)
        }
    }

    func update(_ userTraits: UserTraits) {
        for provider in providers {
            provider.update(userTraits)
        }
    }

    func track(_ event: Event) {
        for provider in providers {
            provider.track(event)
        }
    }
}
