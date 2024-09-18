//
//  NotificationRepresentable.swift
//  Knowledge
//
//  Created by CSH on 24.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// A NotificationRepresentable is an object that can be represented as a Notification type. This type can be used to parse all kind of notifications.
/// If the notifications is only internal, the `AutoNotificationRepresentable` can be used instead.
public protocol NotificationRepresentable {
    /// The related notification name for which this representable is able to parse data. This will be the type as string per default.
    static var name: NSNotification.Name { get }

    /// Creates a new representer using the given notification data.
    ///
    /// - Parameter notification: The posted `Notification` which is used to parse into rich typed data.
    static func from(notification: Notification) -> Self?

    /// Creates a new Notification with a given sender
    /// - Parameter sender: The sender (or obj) that should be used when posting the notification.
    func notification(sender: Any?) -> Notification
}

public extension NotificationRepresentable {
    static var name: NSNotification.Name { NSNotification.Name(String(describing: Self.self)) }
}
