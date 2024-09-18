//
//  LearningCardOptionsRepository.swift
//  Knowledge
//
//  Created by CSH on 17.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import UIKit

/// @mockable
protocol LearningCardOptionsRepositoryType: AnyObject {
    var isHighlightingModeOn: Bool { get set }
    var isHighYieldModeOn: Bool { get set }
    var isPhysikumFokusModeOn: Bool { get set }
    var isLearningRadarOn: Bool { get set }

    func learningCardOptions() -> LearningCardOptions
}

extension LearningCardOptionsRepositoryType {
    func learningCardOptions() -> LearningCardOptions {
        LearningCardOptions(isHighYieldModeOn: isHighYieldModeOn,
                            isHighlightingModeOn: isHighlightingModeOn,
                            isPhysikumFokusModeOn: isPhysikumFokusModeOn,
                            isOnLearningRadarOn: isLearningRadarOn)
    }
}

struct LearningCardOptions {

    let isHighYieldModeOn: Bool
    let isHighlightingModeOn: Bool
    let isPhysikumFokusModeOn: Bool
    let isOnLearningRadarOn: Bool

    // sourcery: fixture:
    init(isHighYieldModeOn: Bool, isHighlightingModeOn: Bool, isPhysikumFokusModeOn: Bool, isOnLearningRadarOn: Bool) {
        self.isHighYieldModeOn = isHighYieldModeOn
        self.isHighlightingModeOn = isHighlightingModeOn
        self.isPhysikumFokusModeOn = isPhysikumFokusModeOn
        self.isOnLearningRadarOn = isOnLearningRadarOn
    }
}

final class LearningCardOptionsRepository: LearningCardOptionsRepositoryType {

    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

    var isHighlightingModeOn: Bool {
        get {
            storage.get(for: .isHighlightingModeEnabled) ?? false
        }
        set {
            let oldValue = isHighlightingModeOn
            storage.store(newValue, for: .isHighlightingModeEnabled)
            NotificationCenter.default.post(HighlightingModeDidChangeNotification(oldValue: oldValue, newValue: newValue), sender: self)
        }
    }

    var isHighYieldModeOn: Bool {
        get {
            storage.get(for: .isHighYieldModeEnabled) ?? false
        }
        set {
            let oldValue = isHighYieldModeOn
            storage.store(newValue, for: .isHighYieldModeEnabled)
            NotificationCenter.default.post(HighYieldModeDidChangeNotification(oldValue: oldValue, newValue: newValue), sender: self)
        }
    }

    var isPhysikumFokusModeOn: Bool {
        get {
            storage.get(for: .isPhysikumFocusModeEnabled) ?? false
        }
        set {
            let oldValue = isPhysikumFokusModeOn
            storage.store(newValue, for: .isPhysikumFocusModeEnabled)
            NotificationCenter.default.post(PhysikumFokusModeDidChangeNotification(oldValue: oldValue, newValue: newValue), sender: self)
        }
    }

    var isLearningRadarOn: Bool {
        get {
            storage.get(for: .isLearningRadarEnabled) ?? false
        }
        set {
            let oldValue = isLearningRadarOn
            storage.store(newValue, for: .isLearningRadarEnabled)
            NotificationCenter.default.post(LearningRadarDidChangeNotification(oldValue: oldValue, newValue: newValue), sender: self)
        }
    }
}
