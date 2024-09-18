//
//  HighYieldModeDidChangeNotification.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 28.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct HighYieldModeDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: Bool
    let newValue: Bool
}
