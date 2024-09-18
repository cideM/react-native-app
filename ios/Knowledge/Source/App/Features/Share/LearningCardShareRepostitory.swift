//
//  LearningCardShareRepostitory.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 07.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

/// @mockable
protocol LearningCardShareRepostitoryType {
    func learningCardShareItem(for learningCardMetaItem: LearningCardMetaItem, with userName: String) -> LearningCardShareItem
}

final class LearningCardShareRepostitory: LearningCardShareRepostitoryType {

    private let configuration: URLConfiguration

    init(configuration: URLConfiguration) {
        self.configuration = configuration
    }

    func learningCardShareItem(for learningCardMetaItem: LearningCardMetaItem, with userName: String) -> LearningCardShareItem {
        let remoteURL = configuration.sharedLearningCardBaseURL
            .appendingPathComponent(learningCardMetaItem.urlPath)

        return LearningCardShareItem(title: L10n.ShareLearningCard.title(userName), message: L10n.ShareLearningCard.message(learningCardMetaItem.title, remoteURL.absoluteString, userName), remoteURL: remoteURL)
    }
}
