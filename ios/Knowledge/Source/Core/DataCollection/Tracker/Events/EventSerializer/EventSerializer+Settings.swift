//
//  SegmentTrackingSerializer+Settings.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 16.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {
    func name(for event: Tracker.Event.Settings) -> String? {
        switch event {
        case .settingsOpened: return "settings_opened"
        case .settingsLogoutClicked: return "settings_logout_clicked"
        case .settingsLogoutCancelled: return "settings_logout_cancelled"
        case .settingsLogoutConfirmed: return "settings_logout_confirmed"
        case .settingsAccountOpened: return "settings_account_opened"
        case .settingsKeepScreenActiveToggled: return "settings_keep_screen_active_toggled"
        case .settingsAppearancePreferenceUpdated: return "settings_appearance_preference_updated"
        }
    }

    func parameters(for event: Tracker.Event.Settings) -> [String: Any]? {
        let parameters = SegmentParameter.Container<SegmentParameter.Settings>()
        switch event {
        case .settingsOpened,
             .settingsLogoutClicked,
             .settingsLogoutCancelled,
             .settingsLogoutConfirmed,
             .settingsAccountOpened:
            return nil
        case .settingsAppearancePreferenceUpdated(let appearancePreference,
                                                  let systemAppearancePreference):
            parameters.set(appearancePreference, for: .appearancePreference)
            parameters.set(systemAppearancePreference, for: .systemAppearancePreference)
        case .settingsKeepScreenActiveToggled(let newValue):
            parameters.set(newValue, for: .newValue)
        }
        return parameters.data
    }
}

extension SegmentParameter {
    enum Settings: String {
        case newValue = "new_value"
        case appearancePreference = "appearance_preference"
        case systemAppearancePreference = "system_appearance_preference"
    }
}
