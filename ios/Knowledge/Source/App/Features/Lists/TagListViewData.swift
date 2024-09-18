//
//  TagListViewData.swift
//  Knowledge
//
//  Created by Silvio Bulla on 10.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct TagListViewData {

    private let learningCardFactory: () -> LearningCardMetaItem?

    var learningCardMetaItem: LearningCardMetaItem? {
        learningCardFactory()
    }

    init(learningCardFactory: @escaping () -> LearningCardMetaItem?) {
        self.learningCardFactory = learningCardFactory
    }
}
