//
//  SharedExtensionRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 29.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

/// @mockable
protocol SharedExtensionRepositoryType: AnyObject {
    var users: [User] { get }

    func add(ext: Extension, for user: User)
    func sharedExtensions(for learningCard: LearningCardIdentifier) -> [SharedExtension]
    func user(with identifier: UserIdentifier) -> User?
    func set(users: [User])

    func removeAllDataFromLocalStorage()
}

final class SharedExtensionRepository: SharedExtensionRepositoryType {

    private let userDefaultsStorage: Storage
    private let fileStorage: Storage

    private(set) var users: [User] {
        didSet {
            userDefaultsStorage.store(users, for: .usersWhoShareExtensionsWithCurrentUser)
        }
    }

    private var sharedExtensions: [SharedExtensionMetadata] {
        didSet {
            fileStorage.store(sharedExtensions, for: .sharedExtensions)
            NotificationCenter.default.post(SharedExtensionsDidChangeNotification(), sender: self)
        }
    }

    init(userDefaultsStorage: Storage, fileStorage: Storage) {
        self.userDefaultsStorage = userDefaultsStorage
        self.fileStorage = fileStorage

        users = userDefaultsStorage.get(for: .usersWhoShareExtensionsWithCurrentUser) ?? []
        sharedExtensions = fileStorage.get(for: .sharedExtensions) ?? []
    }

    func add(ext: Extension, for user: User) {
        // Filter the extension to only leave the extensions that are from a different learning card section or from a different user.
        let filteredExtensions = sharedExtensions.filter { $0.ext.section != ext.section || $0.user.identifier != user.identifier }
        fileStorage.store(ext.note, for: .sharedExtensionNote(ext.section, user.identifier))
        sharedExtensions = filteredExtensions + [SharedExtensionMetadata(user: user, ext: ExtensionMetadata(ext))]
    }

    func sharedExtensions(for learningCard: LearningCardIdentifier) -> [SharedExtension] {
        sharedExtensions
            .filter { $0.ext.learningCard == learningCard }
            .compactMap {
                guard let note = note(for: $0) else { return nil }
                return $0.asSharedExtension(withNote: note)
            }
    }

    func user(with identifier: UserIdentifier) -> User? {
        users.first { $0.identifier == identifier }
    }

    func set(users: [User]) {
        self.users = users
        deleteOrphanedExtensions()
    }

    func removeAllDataFromLocalStorage() {
        sharedExtensions.forEach { fileStorage.store(nil as String?, for: .sharedExtensionNote($0.ext.section, $0.user.identifier)) }
        sharedExtensions = []
        users = []
    }

    private func note(for sharedExtension: SharedExtensionMetadata) -> String? {
        fileStorage.get(for: .sharedExtensionNote(sharedExtension.ext.section, sharedExtension.user.identifier))
    }

    private func deleteOrphanedExtensions() {
        let userIds = users.map { $0.identifier }
        let orphanedExtensions = sharedExtensions.filter { !userIds.contains($0.user.identifier) }
        for orphanedExtension in orphanedExtensions {
            fileStorage.store(nil as String?, for: .sharedExtensionNote(orphanedExtension.ext.section, orphanedExtension.user.identifier))
        }
        sharedExtensions = sharedExtensions.filter { userIds.contains($0.user.identifier) }
    }
}

struct SharedExtensionMetadata: Codable {
    let user: User
    let ext: ExtensionMetadata

    // sourcery: fixture:
    init(user: User, ext: ExtensionMetadata) {
        self.user = user
        self.ext = ext
    }

    func asSharedExtension(withNote note: String) -> SharedExtension {
        SharedExtension(user: user, ext: ext.asExtension(withNote: note))
    }
}

struct SharedExtension: Equatable, Codable {
    let user: User
    let ext: Extension

    // sourcery: fixture:
    init(user: User, ext: Extension) {
        self.user = user
        self.ext = ext
    }
}
