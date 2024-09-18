//
//  AmbossShortcut.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 20.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import CoreSpotlight
import Domain
import IntentsUI
import MobileCoreServices
import Localization

enum AmbossShortcut {
    case search
}

extension AmbossShortcut {
    var deepLink: Deeplink {
        switch self {
        case .search: return .search(nil, source: .siri)
        }
    }

    init?(for activityType: String, configuration: Configuration) {
        switch activityType {
        case configuration.searchActivityType: self = .search
        default: return nil
        }
    }

    func activityType(for configuration: Configuration) -> String {
        switch self {
        case .search: return configuration.searchActivityType
        }
    }

    func userActivity(for configuration: Configuration) -> NSUserActivity {
        switch self {
        case .search: return searchUserActivity(for: configuration)
        }
    }

    func shortcut(for configuration: Configuration) -> INShortcut {
        switch self {
        case .search: return searchShortcut(for: configuration)
        }
    }
}

private extension AmbossShortcut {
    func searchUserActivity(for configuration: Configuration) -> NSUserActivity {
        let activityType = self.activityType(for: configuration)
        let userActivity = NSUserActivity(activityType: activityType)
        userActivity.persistentIdentifier = NSUserActivityPersistentIdentifier(activityType)
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPrediction = true
        userActivity.suggestedInvocationPhrase = L10n.Shortcuts.Search.suggestedInvocationPhrase
        let contentAttributeSet = CSSearchableItemAttributeSet(contentType: UTType.text)
        contentAttributeSet.contentDescription = L10n.Shortcuts.Search.Notification.body

        userActivity.title = L10n.Shortcuts.Search.Notification.title
        userActivity.contentAttributeSet = contentAttributeSet

        return userActivity
    }

    func searchShortcut(for configuration: Configuration) -> INShortcut {
        let searchUserActivity = self.searchUserActivity(for: configuration)
        return INShortcut(userActivity: searchUserActivity)
    }
}
