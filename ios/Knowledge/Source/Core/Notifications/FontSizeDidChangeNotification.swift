//
//  FontSizeDidChangeNotification.swift
//  Knowledge
//
//  Created by Silvio Bulla on 20.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct FontSizeDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: Float?
    let newValue: Float?
}
