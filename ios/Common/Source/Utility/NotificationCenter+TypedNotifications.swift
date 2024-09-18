//
//  NotificationCenter+TypedNotifications.swift
//  Knowledge
//
//  Created by CSH on 24.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

public extension NotificationCenter {

    /// Observes a named notification. This is similar to `NSNotificationCenter.addObserver(forName:object:queue:using:)` but it instead
    /// returns a Cancelable.
    /// As long as the Cancelable isn't released and the `cancel` function of that object isn't called, it will observe the notification. Once the `cancel` function is
    /// called, or the `Cancelable` is released, the observing stops.
    func observe(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> Cancelable {
        let token = addObserver(forName: name, object: obj, queue: queue, using: block)
        return ClosureCancelable { [weak self] in
            self?.removeObserver(token)
        }
    }

    /// The same as `NotificationCenter.observe(forName:object:queue:using:)` but using a `NotificationRepresentable` instead.
    func observe<T: NotificationRepresentable>(for representableType: T.Type, object obj: Any?, queue: OperationQueue?, using block: @escaping (T) -> Swift.Void) -> Cancelable {
        observe(forName: T.name, object: obj, queue: queue) { notification in
            if let notificationRepresenter = T.from(notification: notification) {
                block(notificationRepresenter)
            }
        }
    }

    func post<T: NotificationRepresentable>(_ notification: T, sender: Any?) {
        post(notification.notification(sender: sender))
    }

}
