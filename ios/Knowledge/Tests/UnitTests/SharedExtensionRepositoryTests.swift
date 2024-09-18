//
//  SharedExtensionRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 01.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class SharedExtensionRepositoryTests: XCTestCase {
    var userDefaultsStorage: Storage!
    var fileStorage: Storage!
    var repository: SharedExtensionRepositoryType!

    override func setUp() {
        userDefaultsStorage = MemoryStorage()
        fileStorage = MemoryStorage()
        repository = SharedExtensionRepository(userDefaultsStorage: userDefaultsStorage, fileStorage: fileStorage)
    }

    func testThatSettingTheUsersPersistsThemInTheUserDefaultsStorage() {
        let users = [User.fixture(), User.fixture(), User.fixture()]

        repository.set(users: users)

        let usersStoredInUserDefaultsStorage: [User]? = userDefaultsStorage.get(for: .usersWhoShareExtensionsWithCurrentUser)
        XCTAssertEqual(users, usersStoredInUserDefaultsStorage)
    }

    func testThatCallingUsersOnTheRepositoryReturnsThePersistedUsers() {
        let users = [User.fixture(), User.fixture(), User.fixture()]

        repository.set(users: users)

        XCTAssertEqual(users, repository.users)
    }

    func testThatStoringAnExtensionForASectionInTheRepositoryStoresItsNoteInTheFileStorage() {
        let extensionToStore = Extension.fixture()

        let user = User.fixture()
        repository.add(ext: extensionToStore, for: user)

        let storedExtension: String? = fileStorage.get(for: .sharedExtensionNote(extensionToStore.section, user.identifier))
        XCTAssertEqual(extensionToStore.note, storedExtension)
    }

    func testThatRetrievingTheSharedExtensionsForALearningCardSectionIdentifierReturnsTheCorrectSharedExtensions() {
        let ext1 = Extension.fixture(learningCard: .fixture(value: "spec_1"))
        let ext2 = Extension.fixture(learningCard: .fixture(value: "spec_2"))

        let user1 = User.fixture()
        repository.add(ext: ext1, for: user1)
        repository.add(ext: ext2, for: .fixture())

        XCTAssertEqual([SharedExtension(user: user1, ext: ext1)], repository.sharedExtensions(for: ext1.learningCard))
    }

    func testThatSettingTheUsersWhoShareExtensionsWithCurrentUserRemovesTheExtensionsOfTheUsersWhoDontShareTheirExtensionsAnymore() {
        let user = User.fixture()
        repository.set(users: [user])
        let ext = Extension.fixture()
        repository.add(ext: ext, for: user)

        repository.set(users: [])

        let storedNote: String? = fileStorage.get(for: .sharedExtensionNote(ext.section, user.identifier))
        XCTAssertNil(storedNote)
        let storedSharedExtensionMetadata: [SharedExtensionMetadata]? = fileStorage.get(for: .sharedExtensions)
        XCTAssertFalse(storedSharedExtensionMetadata!.contains { $0.user == user && $0.ext.section == ext.section })
        let fetchedExtensions = repository.sharedExtensions(for: ext.learningCard)
        XCTAssertFalse(fetchedExtensions.contains { $0.ext.section == ext.section })
    }

    func testThatSettingTheUsersWhoShareExtensionsWithCurrentUserDoesntRemoveTheExtensionsOfTheUsersWhoStillShareTheirExtensions() {
        let user1 = User.fixture()
        let user2 = User.fixture()
        repository.set(users: [user1, user2])
        let ext1 = Extension.fixture()
        let ext2 = Extension.fixture()
        repository.add(ext: ext1, for: user1)
        repository.add(ext: ext2, for: user2)

        repository.set(users: [user1])

        let storedNote: String? = fileStorage.get(for: .sharedExtensionNote(ext1.section, user1.identifier))
        XCTAssertEqual(ext1.note, storedNote)
        let storedSharedExtensionMetadata: [SharedExtensionMetadata]? = fileStorage.get(for: .sharedExtensions)
        XCTAssertTrue(storedSharedExtensionMetadata!.contains { $0.user == user1 && $0.ext.section == ext1.section })
        let fetchedExtensions = repository.sharedExtensions(for: ext1.learningCard)
        XCTAssertTrue(fetchedExtensions.contains { $0.ext.section == ext1.section })
    }
}
