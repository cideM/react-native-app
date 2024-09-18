//
//  LibraryUpdaterStateDidChangeNotification.swift
//  Knowledge
//
//  Created by CSH on 24.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct LibraryUpdaterStateDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: LibraryUpdaterState
    let newValue: LibraryUpdaterState
}
