//
//  FeedbacksDidChangeNotification.swift
//  Knowledge
//
//  Created by Silvio Bulla on 26.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct FeedbacksDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: [SectionFeedback]
    let newValue: [SectionFeedback]
}
