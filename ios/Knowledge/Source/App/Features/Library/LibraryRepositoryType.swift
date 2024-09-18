//
//  LibraryRepositoryType.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 27.12.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

/// @mockable
protocol LibraryRepositoryType: AnyObject {
    var library: LibraryType { get set }
    var learningCardStack: PointableStack<LearningCardDeeplink> { get }
    func itemsForParent(_ parent: LearningCardTreeItem?) -> [LearningCardTreeItem]
    func itemForLearningCardIdentifier(_ learningCardIdentifiers: LearningCardIdentifier) -> LearningCardTreeItem?
}
