//
//  Tracker.Event.AppLifecycle.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 16.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
import Foundation

extension Tracker.Event {

    enum AppLifecycle {
        case applicationStarted(appAppearancePreference: AppearancePreference?,
                                systemAppearancePreference: SystemAppearancePreference?)
        case appDefocus
        case appRefocus
        case openURL(URL)
    }

    enum AppearancePreference: String {
        case light
        case dark
        case system
    }

    enum SystemAppearancePreference: String {
        case light
        case dark
    }
}
