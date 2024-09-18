//
//  FeatureFlagRepository.swift
//  Knowledge
//
//  Created by Silvio Bulla on 22.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
import UIKit

/// @mockable
protocol FeatureFlagRepositoryType: AnyObject {
    /// All feature flag data for this user
    var featureFlags: [String] { get set }

    func removeAllDataFromLocalStorage()
}

final class FeatureFlagRepository: FeatureFlagRepositoryType {

    var featureFlags: [String] {
        get {
            storage.get(for: .featureFlags) ?? []
        }
        set {
            guard newValue != featureFlags else { return }
            let oldValue = featureFlags
            storage.store(newValue, for: .featureFlags)
            NotificationCenter.default.post(FeatureFlagsDidChangeNotification(oldValue: oldValue, newValue: newValue), sender: self)
        }
    }

    private let storage: Storage
    private let configuration: Configuration

    init(storage: Storage, configuration: Configuration = AppConfiguration.shared) {
        self.storage = storage
        self.configuration = configuration
    }

    func removeAllDataFromLocalStorage() {
        featureFlags = []
    }
}
