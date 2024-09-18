//
//  AutoNotificationRepresentable.swift
//  Knowledge
//
//  Created by CSH on 24.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// The `AutoNotificationRepresentable` is a `NotificationRepresentable` that will automatically
/// perform the conversion from and to a Foundation.Notification. Every `AutoNotificationRepresentable` will
/// store itself in the `userInfo` of a Notification. Thus it should only be used for internal notifications.
public protocol AutoNotificationRepresentable: NotificationRepresentable {
    /// The key under which the whole object should be stored in the `userInfo`. This will be `Notification` per default.
    static var userInfoKey: String { get }
}

public extension AutoNotificationRepresentable {

    static var userInfoKey: String { "Notification" }

    static func from(notification: Notification) -> Self? {
        guard let userInfo = notification.userInfo,
            let object = userInfo[Self.userInfoKey] as? Self else { return nil }
        return object
    }

    func notification(sender: Any?) -> Notification {
        Notification(name: Self.name, object: sender, userInfo: [
            Self.userInfoKey: self
        ])
    }
}
