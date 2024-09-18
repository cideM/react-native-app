//
//  SegmentTrackingSerializer+Siri.swift
//  Knowledge
//
//  Created by Apeksha Hemanth on 24.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {
    func name(for event: Tracker.Event.Siri) -> String? {
        switch event {
        case .searchSiriShortcutDialogShown: return "search_siri_shortcut_dialog_shown"
        case .searchSiriShortcutDialogAccepted: return "search_siri_shortcut_dialog_accepted"
        case .searchSiriShortcutDialogDeclined: return "search_siri_shortcut_dialog_declined"
        case .searchSiriShortcutExecuted: return "search_siri_shortcut_executed"
        }
    }

    func parameters(for event: Tracker.Event.Siri) -> [String: Any]? {
        switch event {
        case .searchSiriShortcutDialogShown,
             .searchSiriShortcutDialogAccepted,
             .searchSiriShortcutDialogDeclined,
             .searchSiriShortcutExecuted:
            return nil
        }
    }
}
