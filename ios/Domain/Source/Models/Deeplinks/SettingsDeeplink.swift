//
//  SettingsDeeplink.swift
//  Domain
//
//  Created by Roberto Seidenberg on 20.12.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct SettingsDeeplink {

    // sourcery: fixture:
    public enum Screen {
        case appearance
        case productKey(String)
    }

    public let screen: Screen

    // sourcery: fixture:
    public init (screen: SettingsDeeplink.Screen) {
        self.screen = screen
    }

    public init?(urlComponents: URLComponents) {
        switch urlComponents.pathComponents {
        case [.oneOf(["de", "us"]), "settings", "appearance"]:
            self.init(screen: .appearance)
        default:
            // productKey deeplink does not exist as a settings deeplink
            // but it's initialised directly instead in order to handle couponcode deeplinks
            return nil
        }
    }
}

// Implementing this manually cause can not be automated since it's using an associated value for "productKey"
extension SettingsDeeplink: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.screen, rhs.screen) {
        case (.appearance, .appearance):
            return true
        case (let .productKey(lhsKey), let .productKey(rhsKey)):
            return lhsKey == rhsKey
        default:
            return false
        }
    }
}
