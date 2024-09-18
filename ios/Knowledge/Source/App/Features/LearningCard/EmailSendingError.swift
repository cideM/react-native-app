//
//  EmailSendingError.swift
//  Knowledge
//
//  Created by CSH on 11.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

enum EmailSendingError {
    case noEmailClientSetup
}

extension EmailSendingError: PresentableMessageType {
    var debugDescription: String {
        "\(self)"
    }

    var title: String {
        switch self {
        case .noEmailClientSetup: return L10n.EmailSendingError.ClientNotConfigured.title
        }
    }

    var body: String {
        switch self {
        case .noEmailClientSetup: return L10n.EmailSendingError.ClientNotConfigured.message
        }
    }

    var logLevel: MonitorLevel {
        switch self {
        case .noEmailClientSetup: return .warning
        }
    }

}
