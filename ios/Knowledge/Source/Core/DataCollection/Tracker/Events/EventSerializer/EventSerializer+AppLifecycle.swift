//
//  SegmentTrackingSerializer+AppLifecycle.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 16.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {
    func name(for event: Tracker.Event.AppLifecycle) -> String {
        switch event {
        case .applicationStarted: return "application_started"
        case .appDefocus: return "app_defocus"
        case .appRefocus: return "app_refocus"
        case .openURL: return "app_openURL"
        }
    }
    func parameters(for event: Tracker.Event.AppLifecycle) -> [String: Any]? {
        let parameters = SegmentParameter.Container<SegmentParameter.AppLifecycle>()
        switch event {
        case .appRefocus, .appDefocus:
            return nil
        case .applicationStarted(let appearancePreference,
                                 let systemAppearancePreference):
            parameters.set(appearancePreference, for: .appAppearancePreference)
            parameters.set(systemAppearancePreference, for: .systemAppearancePreference)
        case .openURL(let url):
            parameters.set(url.absoluteString, for: .deeplinkURL)
        }
        return parameters.data
    }
}

extension SegmentParameter {
    enum AppLifecycle: String {
        case deeplinkURL = "deeplinkURL"
        case appAppearancePreference = "appearance_preference"
        case systemAppearancePreference = "system_appearance_preference"
    }
}
