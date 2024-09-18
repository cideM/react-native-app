//
//  MessageAction+Default.swift
//  Knowledge
//
//  Created by CSH on 31.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization

// Pre-configured buttons to be used on the fly. For example, a simple error should have a button to dismiss it, this button usually do nothing and it has a normal style.
public extension MessageAction {
    static let dismiss = MessageAction(title: L10n.Generic.alertDefaultButton, style: .normal, handlesError: true)
}
