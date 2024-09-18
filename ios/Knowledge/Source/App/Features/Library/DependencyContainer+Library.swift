//
//  DependencyContainer+Library.swift
//  Knowledge
//
//  Created by CSH on 17.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import DIKit
import Foundation
import Domain

extension DependencyContainer {
    private static let libraryUpdateApplicationService = LibraryUpdateApplicationService(storage: shared.resolve(tag: DIKitTag.Storage.default))
    static var library = module {
        single(tag: DIKitTag.URL.libraryRoot) {
            FileManager.default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first! // swiftlint:disable:this force_unwrapping
                .appendingPathComponent("Articles")
        }
        factory(tag: DIKitTag.URL.partialArchive) { () -> URL in
            Bundle.main.url(forResource: "partialArchive", withExtension: "zip")! // swiftlint:disable:this force_unwrapping
        }
        factory { libraryUpdateApplicationService as LibraryUpdateApplicationServiceType }
        factory { libraryUpdateApplicationService as LibraryUpdaterType }
        single { LibraryRepository() as LibraryRepositoryType }
        single { LibraryUpdaterLegacyCleaner() as LibraryUpdaterLegacyCleanerType }
    }
}
