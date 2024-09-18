//
//  HealthCareProfessionConfirmationDidChangeNotification.swift
//  Knowledge
//
//  Created by Silvio Bulla on 12.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain

struct ProfessionConfirmationDidChangeNotification: AutoNotificationRepresentable {
    var oldValue: Bool?
    var newValue: Bool
}
