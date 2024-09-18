//
//  LearningRadarDidChangeNotification.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 10.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct LearningRadarDidChangeNotification: AutoNotificationRepresentable {
    var oldValue: Bool
    var newValue: Bool
}
