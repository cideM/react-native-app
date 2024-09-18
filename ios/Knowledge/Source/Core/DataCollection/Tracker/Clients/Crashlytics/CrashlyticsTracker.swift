//
//  CrashlyticsTracker.swift
//  Knowledge
//
//  Created by Elmar Tampe on 14.07.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

class CrashlyticsTracker: TrackingType {

    // MARK: - EventTrackingType Conformance
    func set(_ userTraits: [UserTraits]) {
        userTraits.forEach { set($0) }
    }

    func track(_ event: Event) {
        Crashlytics.crashlytics().log("\(event)")
    }

    func update(_ userTraits: UserTraits) {
        set(userTraits)
    }

    // MARK: - Crashlytics
    private func set(_ userProperty: Tracker.UserTraits) {
        switch userProperty {
        case .user(let user): Crashlytics.crashlytics().setUserID(user?.identifier.description ?? "")
        case .deviceId(let deviceId): Crashlytics.crashlytics().setCustomValue(deviceId ?? "", forKey: "device_id")
        case .libraryMetadata(let library) where library != nil: Crashlytics.crashlytics().setCustomValue(library!.versionId, forKey: "library_version") // swiftlint:disable:this force_unwrapping
        case .stage, .studyObjective, .variant, .libraryMetadata, .features: break
        }
    }
}
