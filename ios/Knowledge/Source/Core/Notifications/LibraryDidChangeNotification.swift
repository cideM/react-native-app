//
//  LibraryDidChangeNotification.swift
//  Knowledge
//
//  Created by CSH on 24.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct LibraryDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: LibraryType
    let newValue: LibraryType
}
