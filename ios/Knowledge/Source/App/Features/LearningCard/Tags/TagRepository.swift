//
//  TagRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 10/1/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

/// @mockable
protocol TagRepositoryType: AnyObject {
    /// Adds a tag to a learning card.
    /// - Parameter type: The type of the tag to add.
    /// - Parameter learningCard: The learning card to add the tag to.
    func addTag(_ type: Tag, for learningCard: LearningCardIdentifier)
    /// Removes a tag from a learning card.
    /// - Parameter type: The type of the tag to add.
    /// - Parameter learningCard: The learning card to remove the tag from.
    func removeTag(_ type: Tag, for learningCard: LearningCardIdentifier)
    /// Retruns all the tags for a learning card.
    /// - Parameter learningCard: The learning card to get its tags.
    func tags(for learningCard: LearningCardIdentifier) -> [Tag]
    /// Returns all taggings that where changed since a specific date and are of a given tag type.
    /// - Parameter date: Will only include taggings that were updated after this date.
    /// - Parameter tag: Will only include taggings that have this tag type.
    func taggings(changedSince date: Date?, tags: [Tag]) -> [Tagging]
    /// Imports the given taggings. Existing taggings will be overridden.
    /// - Parameter taggings: The taggings to import.
    func addTags(_ taggings: [Tagging])
    /// Description: fetches Learning card identifiers for a tag
    /// - Parameter tag: accepts a tag of type Tag
    func learningCards(with tag: Tag) -> [LearningCardIdentifier]
    /// Retruns whether a learning card contains a certain tag or not
    /// - Parameters:
    ///   - tag: The tag to check if the learning card has or not.
    ///   - learningCard: The learning card.
    func hasTag(_ tag: Tag, for learningCard: LearningCardIdentifier) -> Bool
    func learningCardsSortedByDate(with tag: Tag) -> [LearningCardIdentifier]

    func removeAllDataFromLocalStorage()
}

final class TagRepository: TagRepositoryType {

    private let storage: Storage

    var taggings: [LearningCardIdentifier: [Tagging]] {
        didSet {
            storage.store(taggings, for: .taggings)
            NotificationCenter.default.post(TaggingsDidChangeNotification(oldValue: oldValue, newValue: taggings), sender: self)
        }
    }

    init(storage: Storage) {
        self.storage = storage
        taggings = storage.get(for: .taggings) ?? [:]
    }

    func addTag(_ type: Tag, for learningCard: LearningCardIdentifier) {
        let tagging = Tagging(type: type, active: true, updatedAt: Date(), learningCard: learningCard)
        addTaggings([tagging])
    }

    func addTags(_ taggings: [Tagging]) {
        self.addTaggings(taggings)
    }

    func removeTag(_ type: Tag, for learningCard: LearningCardIdentifier) {
        let tagging = Tagging(type: type, active: false, updatedAt: Date(), learningCard: learningCard)
        addTaggings([tagging])
    }

    func tags(for learningCard: LearningCardIdentifier) -> [Tag] {
        guard let tags = taggings[learningCard] else { return [] }
        return tags
            .filter { $0.active }
            .map { $0.type }
    }

    func taggings(changedSince date: Date?, tags: [Tag]) -> [Tagging] {
        taggings.values
            .flatMap { $0 }
            // is there a way to write this nicer?
            .filter { tags.contains($0.type) && (date == nil || $0.updatedAt > date!) } // swiftlint:disable:this force_unwrapping
    }

    func hasTag(_ tag: Tag, for learningCard: LearningCardIdentifier) -> Bool {
        tags(for: learningCard).contains { $0 == tag }
    }

    func learningCards(with tag: Tag) -> [LearningCardIdentifier] {
        taggings.values
            .flatMap { $0 }
            .filter { $0.type == tag && $0.active }
            .map { $0.learningCard }
    }

    func learningCardsSortedByDate(with tag: Tag) -> [LearningCardIdentifier] {
        taggings.values
            .flatMap { $0 }
            .filter { $0.type == tag && $0.active }
            .sorted { $0.updatedAt > $1.updatedAt }
            .map { $0.learningCard }
    }

    func removeAllDataFromLocalStorage() {
        taggings = [:]
    }

    private func addTaggings(_ newTaggings: [Tagging]) {

        // Make sure there exists only one tagging of each kind (learned, favorited or opened) for each leanring card ...
        var dedupedTaggings = self.taggings
        for newTagging in newTaggings {
            var existingTaggings = dedupedTaggings[newTagging.learningCard]?.filter { $0.type != newTagging.type } ?? []
            existingTaggings.append(newTagging)
            dedupedTaggings[newTagging.learningCard] = existingTaggings
        }

        // Only set the main propertay now, cause this triggers a notification
        // Settings this for each single tagging change might lead to excessive UI updates
        self.taggings = dedupedTaggings
    }
}
