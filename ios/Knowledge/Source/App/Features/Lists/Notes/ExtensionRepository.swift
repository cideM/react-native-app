//
//  ExtensionRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 10/1/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

/// @mockable
protocol ExtensionRepositoryType {
    func set(ext: Extension)
    func extensions(for learningCard: LearningCardIdentifier) -> [Extension]
    func extensionsMetaData() -> [ExtensionMetadata]
    func extensionForSection(_ section: LearningCardSectionIdentifier) -> Extension?
    func extensionsToBeUploaded() -> [Extension]

    func removeAllDataFromLocalStorage()
}

final class ExtensionRepository: ExtensionRepositoryType {

    private let storage: Storage
    /// A property that contains all the saved extensions.
    ///
    /// We save the extensions as instances of `ExtensionMetadata` for memory-related reasons.
    ///
    /// An extension contains a `note` property among other properties. the `note` property can be any length text. And we don't want this text to be in memory all the time. We'll only get it once we really need it.
    ///
    /// So we save the extensions as instances of `ExtensionMetadata`, which contains everything in an extension except for the note itself.
    ///
    /// The note can be retrieved from memory by a key; This key is the result of concatinating the `learningCard` and `section` properties of the extension.
    private var extensions: [ExtensionMetadata] {
        didSet {
            storage.store(extensions, for: .extensions)
            NotificationCenter.default.post(ExtensionsDidChangeNotification(oldValue: oldValue, newValue: extensions), sender: self)
        }
    }

    init(storage: Storage) {
        self.storage = storage
        extensions = storage.get(for: .extensions) ?? []
    }

    /// Adds a new extenstion.
    /// - Parameter ext: The extension to add.
    func set(ext: Extension) {
        // Filter the extension to only leave the extensions that are from a different learning card section.
        let filteredExtensions = extensions.filter { $0.section != ext.section }
        storage.store(ext.note, for: .extensionNote(ext.section))
        extensions = filteredExtensions + [ExtensionMetadata(ext)]
    }

    func extensionsMetaData() -> [ExtensionMetadata] {
        extensions
    }

    /// Returns the extensions in a certain learning card.
    /// - Parameter sections: The sections of a learning card to return its extensions.
    func extensionForSection(_ section: LearningCardSectionIdentifier) -> Extension? {
        guard let note: String = note(for: section) else { return nil }
        return extensions.first { $0.section == section }?
            .asExtension(withNote: note)
    }

    func extensions(for learningCard: LearningCardIdentifier) -> [Extension] {
        extensions
            .filter { $0.learningCard == learningCard }
            .compactMap { extensionForSection($0.section) }
    }

    /// Returns all the extensions that need to be synchronized.
    func extensionsToBeUploaded() -> [Extension] {
        let extMetaArray = extensions.filter { $0.needsSynchronization }
        let extArray = extMetaArray.compactMap { metaItem -> Extension? in
            guard let note = note(for: metaItem.section) else { return nil }
            return metaItem.asExtension(withNote: note)
        }
        return extArray
    }

    func removeAllDataFromLocalStorage() {
        extensions.forEach { storage.store(nil as String?, for: .extensionNote($0.section)) }
        extensions = []
    }

    private func note(for section: LearningCardSectionIdentifier) -> String? {
        storage.get(for: .extensionNote(section))
    }
}

struct ExtensionMetadata: Codable {
    let learningCard: LearningCardIdentifier
    let section: LearningCardSectionIdentifier
    let updatedAt: Date
    let previousUpdatedAt: Date?
    let isEmptyNote: Bool

    var needsSynchronization: Bool {
        guard let previousUpdatedAt = previousUpdatedAt else { return true }
        return previousUpdatedAt != updatedAt
    }

    // sourcery: fixture:
    init(_ ext: Extension) {
        learningCard = ext.learningCard
        section = ext.section
        updatedAt = ext.updatedAt
        isEmptyNote = ext.unformattedNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        previousUpdatedAt = ext.previousUpdatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        learningCard = try container.decode(LearningCardIdentifier.self, forKey: .learningCard)
        section = try container.decode(LearningCardSectionIdentifier.self, forKey: .section)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        previousUpdatedAt = try? container.decode(Date.self, forKey: .previousUpdatedAt)
        isEmptyNote = (try? container.decode(Bool.self, forKey: .isEmptyNote)) ?? false
    }

    func asExtension(withNote note: String) -> Extension {
        Extension(learningCard: learningCard, section: section, updatedAt: updatedAt, previousUpdatedAt: previousUpdatedAt, note: note)
    }
}
