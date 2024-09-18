//
//  FeatureFlagsDidChangeNotification.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 01.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

struct FeatureFlagsDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: [String]
    let newValue: [String]
}
