//
//  PharmaOfflineDatabaseDidChangeNotification.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 14.04.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain

struct PharmaOfflineDatabaseApplicationServiceDidChangeStateNotification: AutoNotificationRepresentable {
    let oldValue: PharmaDatabaseApplicationServiceState
    let newValue: PharmaDatabaseApplicationServiceState
}
