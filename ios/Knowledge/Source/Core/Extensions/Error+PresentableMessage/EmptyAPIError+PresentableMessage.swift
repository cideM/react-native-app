//
//  EmptyAPIError+PresentableMessage.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 14.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

extension EmptyAPIError: PresentableMessageType {

    public var debugDescription: String {
        "\(self)"
    }

    public var title: String {
        switch self { }
    }

    public var body: String {
        switch self { }
    }

    public var logLevel: MonitorLevel {
        switch self { }
    }
}
