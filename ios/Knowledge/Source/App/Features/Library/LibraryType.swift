//
//  LibraryType.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 23.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

/// @mockable
protocol LibraryType: AnyObject {
    var metadata: LibraryMetadata { get }

    /// Initializes the Library with a path URL.
    /// - Parameter url: Path to library zip file.
    init(with zip: URL) throws

    var url: URL { get }

    /// An array containing all the learning cards of a library.
    var learningCardTreeItems: [LearningCardTreeItem] { get }

    func move(toParent folder: URL)

    func gallery(with identifier: GalleryIdentifier) throws -> Gallery
    func imageResource(for identifier: ImageResourceIdentifier) throws -> ImageResourceType

    /// This function checks if a Snippet with a specific LearningCardDeeplink exists and returns it.
    /// - Parameter learningCardDeeplink: The LearningCardDeeplink that will be used for checking.
    func snippet(for learningCardDeeplink: LearningCardDeeplink) throws -> Snippet?

    /**
        Returns the snippet with the given identifier from the library, if it exists. Otherwise, it returns nil
        - Parameter withIdentifier: snippet identifier
        - Returns: The snippet with the given identifier or nil
     */
    func snippet(withIdentifier identifier: SnippetIdentifier) throws -> Snippet?

    func learningCardMetaItem(for identifier: LearningCardIdentifier) throws -> LearningCardMetaItem

    func learningCardHtmlBody(for learningCard: LearningCardIdentifier) throws -> String

    func data(at path: String) throws -> Data

    var autolinks: [Autolink] { get }
}
