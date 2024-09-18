//
//  UserStageDidChangeNotification.swift
//  Knowledge
//
//  Created by CSH on 29.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct UserStageDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: UserStage?
    let newValue: UserStage?
}
