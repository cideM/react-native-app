//
//  Tracker.Event.Settins.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 16.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension Tracker.Event {

    enum Settings {
        case settingsOpened
        case settingsLogoutClicked
        case settingsLogoutCancelled
        case settingsLogoutConfirmed
        case settingsAccountOpened
        case settingsKeepScreenActiveToggled(newValue: Bool)
        case settingsAppearancePreferenceUpdated(appearancePreference: AppearancePreference?,
                                                 systemAppearancePreference: SystemAppearancePreference?)
    }
}
