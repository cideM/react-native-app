//
//  TaggingsDidChangeNotification.swift
//  Knowledge
//
//  Created by Silvio Bulla on 26.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct TaggingsDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: [LearningCardIdentifier: [Tagging]]
    let newValue: [LearningCardIdentifier: [Tagging]]
}
