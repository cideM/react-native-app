//
//  UserTraitsSegmentPlugin.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 02.11.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Segment

/// This is a Segment Plugin that intercepts the userTraits from Identify event
/// and adds them to the track event payload as needed.
/// When this plugin is used, the userTraits will be sent in:
///  - The Identify event as 'traits'
///  - The Track event's properties under 'traits'
///  - The Track event as key values in the event properties themselves.
class UserTraitsSegmentPlugin: Segment.EventPlugin {
    private static let traitsKey = "traits"
    var type: Segment.PluginType = .enrichment
    weak var analytics: Segment.Analytics?

    func track(event: TrackEvent) -> TrackEvent? {
        var event = event
        let normalizedProperties = mergedTrackingEventPayload(
            eventParameters: event.properties?.dictionaryValue ?? [:],
            userTraits: analytics?.traits() ?? [:])

        // Add the user traits to the event context
        if var context = event.context?.dictionaryValue {
            context[keyPath: KeyPath(Self.traitsKey)] = analytics?.traits()
            event.context = try? JSON(context)
        }

        // Add the user traits to the event parameters
        let jsonProperties = try? JSON(normalizedProperties)
        event.properties = jsonProperties
        return event
    }

    func mergedTrackingEventPayload(eventParameters: [String: Any],
                                    userTraits: [String: Any]) -> [String: Any] {
        // The order how this is merged is important!
        // If a user trait has the same key as any other event property we want the event property to overwrite the user trait
        // The original user traits are going to sent separately in each tracking event's properties under 'traits'
        // We are merging "userTraits" and "eventParameters" here for historical reasons
        // There was a time when the app did not send user traits and some tracking infrastructure
        // started relying on all the data being available in the event itself.
        // Hence we do not want to take the data out again because it might break things.
        // Just giving the actual events properties precedence over user traits" seems to work well enough.
        userTraits.merging(eventParameters) { $1 }
    }
}
