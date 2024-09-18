//
//  DependencyContainer+LibraryTesting.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 27.12.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import DIKit
import Foundation

extension DependencyContainer {
    static var librarytesting = module {
        single(tag: DIKitTag.URL.libraryRoot) {
            FileManager.default.temporaryDirectory.appendingPathComponent("LibraryUpdateApplicationServiceTest-baseFolder")
        }
        factory(tag: DIKitTag.URL.partialArchive) { () -> URL in
            // swiftlint:disable force_unwrapping
            Bundle.main.url(forResource: "partialArchive", withExtension: "zip")!
        }
        single { LibraryRepository() as LibraryRepositoryType }
    }
}
