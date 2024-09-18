//
//  UIUserInterfaceStyle+Tracking.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 15.12.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit

extension UIUserInterfaceStyle {
    func trackingPreference() -> Tracker.Event.AppearancePreference? {
        switch self {
        case .unspecified:
            return .system
        case .light:
            return .light
        case .dark:
            return .dark
        @unknown default:
            return nil
        }
    }

    func trackingSystemPreference() -> Tracker.Event.SystemAppearancePreference? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .unspecified:
            return nil
        @unknown default:
            return nil
        }
    }
}
