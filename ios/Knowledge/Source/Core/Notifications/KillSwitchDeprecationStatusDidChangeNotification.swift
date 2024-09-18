//
//  KillSwitchDeprecationStatusDidChangeNotification.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 24.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct KillSwitchDeprecationStatusDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: KillSwitchDeprecationStatus
    let newValue: KillSwitchDeprecationStatus
}
