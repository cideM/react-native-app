//
//  LibraryRepositoryDidInitializeNotification.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 30.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct LibraryRepositoryDidInitializeNotification: AutoNotificationRepresentable {
    let libraryRepository: LibraryRepositoryType
}
