//
//  ShortcutsService.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 19.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import IntentsUI
import UIKit

/// @mockable
protocol ShortcutsServiceType: AnyObject {
    func deepLink(for userActivity: NSUserActivity) -> Deeplink?
    func userActivity(for shortcut: AmbossShortcut) -> NSUserActivity
    func newAddVoiceShortcutViewController(for shortcut: AmbossShortcut, delegate: INUIAddVoiceShortcutViewControllerDelegate) -> UIViewController
}

final class ShortcutsService: ShortcutsServiceType {
    private let appConfiguration: Configuration

    init(appConfiguration: Configuration = AppConfiguration.shared) {
        self.appConfiguration = appConfiguration
    }

    func deepLink(for userActivity: NSUserActivity) -> Deeplink? {
        let ambossShortcut = AmbossShortcut(for: userActivity.activityType, configuration: appConfiguration)
        return ambossShortcut?.deepLink
    }

    func userActivity(for shortcut: AmbossShortcut) -> NSUserActivity {
        shortcut.userActivity(for: appConfiguration)
    }

    func newAddVoiceShortcutViewController(for ambossShortcut: AmbossShortcut, delegate: INUIAddVoiceShortcutViewControllerDelegate) -> UIViewController {
        let viewController = INUIAddVoiceShortcutViewController(shortcut: ambossShortcut.shortcut(for: appConfiguration))
        viewController.delegate = delegate
        return viewController
    }
}
