//
//  LoginAPIError+PresentableMessage.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/11/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

extension LoginAPIError: PresentableMessageType {

    public var debugDescription: String {
        "\(self)"
    }

    public var title: String {
        L10n.Login.Error.title
    }

    public var body: String {
        switch self {
        case .other(let localizedMessage): return localizedMessage
        }
    }

    public var logLevel: MonitorLevel {
        switch self {
        case .other: return .warning
        }
    }
}
