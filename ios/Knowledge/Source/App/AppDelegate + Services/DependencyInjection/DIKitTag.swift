//
//  DIKitTag.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 01.02.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import DIKit
import Foundation

enum DIKitTag {}

// Storage
func resolve(tag: DIKitTag.Storage) -> Storage { DependencyContainer.shared.resolve(tag: tag) }

extension DIKitTag {
    enum Storage: String {
        case `default`
        case large // for storing larg(er) amounts of data
        case secure // to store data in a secure way
    }
}

// URL
func resolve(tag: DIKitTag.URL) -> URL { DependencyContainer.shared.resolve(tag: tag) }

extension DIKitTag {
    enum URL: String {
        case libraryRoot
        case partialArchive
    }
}
