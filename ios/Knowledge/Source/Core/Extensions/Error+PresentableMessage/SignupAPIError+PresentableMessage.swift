//
//  SignupAPIError+PresentableMessage.swift
//  Knowledge
//
//  Created by Silvio Bulla on 14.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

extension SignupAPIError: PresentableMessageType {

    public var debugDescription: String {
        "\(self)"
    }

    public var title: String {
        switch self {
        case .emailAlreadyRegistered:
            return L10n.Error.Generic.title
        }
    }

    public var body: String {
        switch self {
        case .emailAlreadyRegistered:
            return L10n.Password.errorEmailAlreadyRegistered
        }
    }

    public var logLevel: MonitorLevel {
        switch self {
        case .emailAlreadyRegistered: return MonitorLevel.warning
        }
    }
}
