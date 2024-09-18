//
//  ExtensionsDidChangeNotification.swift
//  Knowledge
//
//  Created by Silvio Bulla on 02.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct ExtensionsDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: [ExtensionMetadata]
    let newValue: [ExtensionMetadata]
}
