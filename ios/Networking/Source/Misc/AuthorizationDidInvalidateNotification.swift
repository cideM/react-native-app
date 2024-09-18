//
//  AuthorizationDidInvalidateNotification.swift
//  Networking
//
//  Created by Cornelius Horstmann on 17.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

public struct AuthorizationDidInvalidateNotification: AutoNotificationRepresentable {
    public let oldAuthorization: Authorization
    public let developerDescription: String

    public init(oldAuthorization: Authorization, developerDescription: String) {
        self.oldAuthorization = oldAuthorization
        self.developerDescription = developerDescription
    }
}
