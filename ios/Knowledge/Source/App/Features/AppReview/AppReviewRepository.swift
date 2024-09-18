//
//  AppReviewRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 24.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

/// @mockable
protocol AppReviewRepositoryType {
    func shouldDisplayAppReviewPrompt() -> Bool
    func appReviewPromptWasDisplayed()
}

final class AppReviewRepository: AppReviewRepositoryType {

    private let storage: Storage
    private let minAppLaunchCount: Int
    private let minArticleViewCount: Int
    private let timeIntervalSinceFirstAppLaunch: TimeInterval
    private let timeIntervalSinceLastAppPromptDisplay: TimeInterval

    private var appLaunchCount: Int {
        get {
            storage.get(for: .appLaunchCount) ?? 0
        }
        set {
            storage.store(newValue, for: .appLaunchCount)
        }
    }

    private var articleViewCount: Int {
        get {
            storage.get(for: .articleViewCount) ?? 0
        }
        set {
            storage.store(newValue, for: .articleViewCount)
        }
    }

    private var firstAppLaunchDate: Date? {
        get {
            storage.get(for: .firstAppLaunchDate)
        }
        set {
            storage.store(newValue, for: .firstAppLaunchDate)
        }
    }

    private var appReviewPromptLastDisplayDate: Date? {
        get {
            storage.get(for: .appReviewPromptLastDisplayDate)
        }
        set {
            storage.store(newValue, for: .appReviewPromptLastDisplayDate)
        }
    }

    init(storage: Storage, minAppLaunchCount: Int = 10, minArticleViewCount: Int = 20, timeIntervalSinceFirstAppLaunch: TimeInterval = 1.0.week, timeIntervalSinceLastAppPromptDisplay: TimeInterval = 90.0.days) {
        self.storage = storage
        self.minAppLaunchCount = minAppLaunchCount
        self.minArticleViewCount = minArticleViewCount
        self.timeIntervalSinceFirstAppLaunch = timeIntervalSinceFirstAppLaunch
        self.timeIntervalSinceLastAppPromptDisplay = timeIntervalSinceLastAppPromptDisplay
    }

    func shouldDisplayAppReviewPrompt() -> Bool {
        func didPassEnoughTimeSinceLastAppReviewPromptDisplay() -> Bool {
            guard let appReviewPromptLastDisplayDate = appReviewPromptLastDisplayDate else { return true }
            return Date().timeIntervalSince(appReviewPromptLastDisplayDate) >= timeIntervalSinceLastAppPromptDisplay
        }

        guard let firstAppLaunchDate = firstAppLaunchDate else { return false }

        return Date().timeIntervalSince(firstAppLaunchDate) >= timeIntervalSinceFirstAppLaunch &&
            appLaunchCount >= minAppLaunchCount &&
            articleViewCount >= minArticleViewCount &&
            didPassEnoughTimeSinceLastAppReviewPromptDisplay()

    }

    func appReviewPromptWasDisplayed() {
        appReviewPromptLastDisplayDate = Date()
    }
}

extension AppReviewRepository: TrackingType {
    func set(_ userProperties: [Tracker.UserTraits]) {}
    func update(_ userProperty: Tracker.UserTraits) {}

    func track(_ event: Tracker.Event) {
        switch event {
        case .appLifecycle(let event):
            switch event {
            case .applicationStarted:
                if firstAppLaunchDate == nil {
                    firstAppLaunchDate = Date()
                }
                appLaunchCount += 1
            default:
                break
            }

        case .article(let event):
            switch event {
            case .articleOpened:
                articleViewCount += 1
            default:
                break
            }

        default:
            break
        }
    }
}
