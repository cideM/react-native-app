//
//  DependencyContainer+Storage.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 05.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import DIKit
import Foundation

extension DependencyContainer {
    static var storage = module {
        single(tag: DIKitTag.Storage.default) { UserDefaultsStorage(.standard) as Storage }
        single(tag: DIKitTag.Storage.secure) { KeychainStorage() as Storage }
        // swiftlint:disable:next force_unwrapping
        single(tag: DIKitTag.Storage.large) { FileStorage(with: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("filestorage")) as Storage }
    }
}
