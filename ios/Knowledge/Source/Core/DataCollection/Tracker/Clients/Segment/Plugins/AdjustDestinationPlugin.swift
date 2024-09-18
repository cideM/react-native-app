//
//  AdjustDestinationPlugin.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 02.11.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Segment

public class AdjustDestinationPlugin: Segment.EventPlugin {
    public var type: Segment.PluginType = .enrichment
    public weak var analytics: Segment.Analytics?
    @LazyInject private var attributionTrackingService: AttributionTrackingApplicationServiceType

    public func track(event: TrackEvent) -> TrackEvent? {
        var event = event
        event.integrations = .object(["Adjust": .bool(attributionTrackingService.isEnabled)])
        return event
    }
}
