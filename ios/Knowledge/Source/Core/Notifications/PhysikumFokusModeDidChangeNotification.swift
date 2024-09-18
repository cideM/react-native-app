//
//  PhysikumFokusModeDidChangeNotification.swift
//  Knowledge
//
//  Created by Silvio Bulla on 28.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct PhysikumFokusModeDidChangeNotification: AutoNotificationRepresentable {
    var oldValue: Bool
    var newValue: Bool
}
