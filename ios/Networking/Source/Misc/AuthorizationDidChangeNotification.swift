//
//  AuthorizationDidChangeNotification.swift
//  Networking
//
//  Created by CSH on 24.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

public struct AuthorizationDidChangeNotification: AutoNotificationRepresentable {
    public let oldValue: Authorization?
    public let newValue: Authorization?

    public init(oldValue: Authorization?, newValue: Authorization?) {
        self.oldValue = oldValue
        self.newValue = newValue
    }
}
