//
//  ExtensionViewData.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 21.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct ExtensionViewData {
    private let extensionFactory: () -> Extension?
    var ext: Extension? {
        extensionFactory()
    }

    private let learningCardFactory: () -> LearningCardMetaItem?
    var learningCard: LearningCardMetaItem? {
        learningCardFactory()
    }

    init(extensionFactory: @escaping () -> Extension?, learningCardFactory: @escaping () -> LearningCardMetaItem?) {
        self.extensionFactory = extensionFactory
        self.learningCardFactory = learningCardFactory
    }
}
