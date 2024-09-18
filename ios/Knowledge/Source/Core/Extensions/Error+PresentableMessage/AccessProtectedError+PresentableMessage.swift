//
//  AccessProtectedError+PresentableMessage.swift
//  Knowledge
//
//  Created by CSH on 17.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

extension AccessProtectedError: PresentableMessageType {

    public var debugDescription: String {
        "\(self)"
    }

    public var title: String {
        switch self {
        case .accessBlocked: return L10n.Error.Generic.title
        }
    }

    public var body: String {
        switch self {
        case .accessBlocked: return L10n.Error.Generic.message
        }
    }

    public var logLevel: MonitorLevel {
        switch self {
        case .accessBlocked: return MonitorLevel.warning
        }
    }
}
