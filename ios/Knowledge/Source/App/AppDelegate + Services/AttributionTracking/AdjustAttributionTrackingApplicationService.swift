//
//  AdjustAttributionTrackingApplicationService.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 03.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Adjust
import UIKit
import Networking

/// @mockable
protocol AdjustType {
    static func isEnabled() -> Bool
    static func setEnabled(_ enabled: Bool)
    static func appDidLaunch(_ adjustConfig: ADJConfig?)
    static func requestTrackingAuthorization(completionHandler completion: ((UInt) -> Void)?)
    static func addSessionPartnerParameter(_ key: String, value: String)
    static func removeSessionPartnerParameter(_ key: String)
}

extension Adjust: AdjustType {}

final class AdjustAttributionTrackingApplicationService: AttributionTrackingApplicationServiceType {
    private static let sessionParameterAnonymousIdKey = "anonymous_id"

    private let adjust: AdjustType.Type
    private let configuration: TrackingConfiguration & FeatureConfiguration
    private let storage: Storage
    private let segmentTracker: SegmentTrackerType

    private var authorizationObserver: NSObjectProtocol?

    var isEnabled: Bool {
        adjust.isEnabled()
    }

    init(adjust: AdjustType.Type = Adjust.self,
         segmentTracker: SegmentTrackerType = resolve(),
         configuration: TrackingConfiguration & FeatureConfiguration = AppConfiguration.shared,
         storage: Storage = resolve(tag: .default)
    ) {
        self.adjust = adjust
        self.configuration = configuration
        self.storage = storage
        self.segmentTracker = segmentTracker

        self.registerNotifications()
    }

    private func registerNotifications() {
        authorizationObserver = NotificationCenter.default
            .observe(for: AuthorizationDidChangeNotification.self,
                     object: nil,
                     queue: .main) { [weak self] notification in
                if notification.newValue == nil {
                    self?.reset()
                }
            }
    }

    func application(_ application: UIApplicationType,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let environment: String
        #if DEBUG || QA
            environment = ADJEnvironmentSandbox
        #else
            environment = ADJEnvironmentProduction
        #endif
        let adjustConfig = ADJConfig(appToken: configuration.adjustAppToken, environment: environment)

        #if DEBUG
        adjustConfig?.logLevel = ADJLogLevelSuppress
        #endif

        adjust.appDidLaunch(adjustConfig)

        // Set the previous enabled state again on launch
        // since the Adjust SDK expects this to be called
        // in didFinishLaunchingWithOptions
        let adjustWasEnabled: Bool = storage.get(for: .userGaveAdjustConsent) ?? false

        adjust.setEnabled(adjustWasEnabled)
        adjust.addSessionPartnerParameter(Self.sessionParameterAnonymousIdKey, value: segmentTracker.anonymousId)

        return true
    }

    func reset() {
        // Disable adjust, it will be enabled again when the
        // user is logged in and accepts the tracking consent
        adjust.setEnabled(false)
        storage.store(false, for: .userGaveAdjustConsent)
    }
}

extension AdjustAttributionTrackingApplicationService: ConsentChangeListener {
    func consentDidChange(_ consents: [ConsentService: Bool]) {

        guard consents[.adjust] == true else {
            adjust.setEnabled(false)
            storage.store(false, for: .userGaveAdjustConsent)
            return
        }
        adjust.requestTrackingAuthorization { [weak self] _ in
            guard let self else { return }
            // We wait for the response of the tracking authorization request. (its a system dialog)
            // In case the user approved it, the SDK will use the IDFA. Otherwise, the SDK will use other ways to identify the user.
            let isEnabled = consents[.adjust] ?? false
            self.adjust.setEnabled(isEnabled)
            self.adjust.addSessionPartnerParameter(Self.sessionParameterAnonymousIdKey, value: self.segmentTracker.anonymousId)
            self.storage.store(isEnabled, for: .userGaveAdjustConsent)
        }
    }
}
