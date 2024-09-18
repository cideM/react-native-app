//
//  SegmentTracker.swift
//  Knowledge
//
//  Created by Elmar Tampe on 14.07.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Segment

/// @mockable
protocol SegmentTrackerType: TrackingType {
    var anonymousId: String { get }
}

class SegmentTracker: SegmentTrackerType {
    private static let userTraitsUserIdKey = "user_id"
    private var userTraitsDictionary: [String: Any] = [:]
    private let eventSerializer = EventSerializer()
    private var client: Segment.Analytics
    @Inject var remoteConfigRepository: RemoteConfigRepositoryType
    var anonymousId: String {
        client.anonymousId
    }

    // MARK: - Initialization
    init() {
        client = Segment.Analytics(configuration: SegmentTracker.defaultConfiguration())
        client.add(plugin: AdjustDestinationPlugin())
        client.add(plugin: UserTraitsSegmentPlugin())
    }

    // MARK: - EventTrackingType Conformance
    func set(_ userTraits: [UserTraits]) {
        // Normalize the userTraits array into the expected dictionary
        let parameters = userTraits.compactMap { eventSerializer.parameters(for: $0) }.flatMap { $0 }
        self.userTraitsDictionary = Dictionary(parameters) { _, last in last }

        if let userId = userTraitsDictionary[Self.userTraitsUserIdKey] as? String {
            identify(id: userId, traits: userTraitsDictionary)
        }
    }

    func track(_ event: Event) {
        // DeepLing tracking is handled by the SDK itself. To integrate the event in our data structure we are using
        // the `appLifecycle(.openURL(url))` event. If the event matches the given case pattern we do not track the
        // default way, we use the SDK's `openURL(url)` function. If the event does not match we do the regular way
        // of tracking the payload.
        if case let Event.appLifecycle(.openURL(url)) = event {
            // Not opening a URL! -> Default Deeplink tracking implementation of Segment.
            client.openURL(url)
            return
        }

        guard let name = eventSerializer.name(for: event) else { return }
        let parameters = eventSerializer.parameters(for: event) ?? [:]

        client.track(name: name, properties: parameters)
    }

    func update(_ userTraits: UserTraits) {

        guard let parameters = eventSerializer.parameters(for: userTraits) else { return }
        parameters.keys.forEach { self.userTraitsDictionary[$0] = parameters[$0] }

        if let userId = userTraitsDictionary[Self.userTraitsUserIdKey] as? String {
            identify(id: userId, traits: userTraitsDictionary)
        }
    }

    // MARK: - Segment Internals
    private func identify(id: String, traits: [String: Any]) {
        // WORKAROUND: Inject user group for iOS IAP 5 day trial removal experiment.
        // This is the easiest place to inject this without needing to create logic
        // for converting each of the user traits into JSON objects. Attempting to
        // inject this via a Segment plugin, requires implementing the conversion
        // from [Sring : Any] to [Sring: JSON] type. But Injecting it here allows
        // us to make use of the identify(userId: String, traits: [String: Any])
        // overload that is defined by the Segment SDK. This workaround is temporary
        // and will only live for the duration of the experiment.
        var traits = traits
        var features = traits[SegmentParameter.UserProperty.features.rawValue] as? [String] ?? []
        let iapExperimentUserGroup: String = {
            if remoteConfigRepository.iap5DayTrialRemoved {
                return "iap_experiment_remove_5day_trial_group_variant"
            } else {
                return "iap_experiment_remove_5day_trial_group_control"
            }
        }()

        features.append(iapExperimentUserGroup)
        traits[SegmentParameter.UserProperty.features.rawValue] = features
        client.identify(userId: id, traits: traits)
    }

    // MARK: - Default Configuration
    private static func defaultConfiguration() -> Segment.Configuration {

        let trackingConfiguration: TrackingConfiguration = AppConfiguration.shared

        let writeKey = trackingConfiguration.segmentAnalyticsWriteKey
        let flushAt = trackingConfiguration.segmentAnalyticsFlushAt
        let trackApplicationLifecycleEvents = trackingConfiguration.segmentTrackApplicationLifecycleEvents
        let configuration = Segment.Configuration(writeKey: writeKey)

        // Set a custom request factory which allows us to modify the way the library creates an HTTP request.
        // In this case, we're transforming the URL to point to our own custom non-Segment host.
        // But don't proxy GET requests as they are fetching settings from the segment servers.
        let requestFactory: (URLRequest) -> URLRequest = { request in
            var request = request
            if let url = request.url,
               request.httpMethod != "GET",
               var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                components.host = trackingConfiguration.segmentProxyURLHost
                components.path = trackingConfiguration.segmentProxyURLPath
                if let transformedURL = components.url {
                    request.url = transformedURL
                }
            }

            return request
        }

        // We are proxing the data to our own servers which forward
        // it to Segment. This is due to GDPR Related reasons.
        configuration.requestFactory(requestFactory)
        configuration.flushAt(flushAt)
        configuration.trackApplicationLifecycleEvents(trackApplicationLifecycleEvents)

        return configuration
    }
}
