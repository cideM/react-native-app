//
//  AttributionTrackingApplicationServiceType.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 03.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

/// @mockable
protocol AttributionTrackingApplicationServiceType: AnyObject, ApplicationService, ConsentChangeListener {
    var isEnabled: Bool { get }
    func reset()
}
