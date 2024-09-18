//
//  UnkownError+PresentableMessage.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 29.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

extension UnknownError: PresentableMessageType {
    public var debugDescription: String {
        "\(self)"
    }

    public var title: String {
        L10n.Error.Generic.title
    }

    public var body: String {
        L10n.Error.Generic.message
    }

    public var logLevel: MonitorLevel {
        .warning
    }
}
