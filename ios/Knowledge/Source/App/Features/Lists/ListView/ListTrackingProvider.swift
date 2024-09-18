//
//  ListTrackingProvider.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 16.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

/// @mockable
protocol ListTrackingProvider {
    func track(learningCard identifier: LearningCardIdentifier, tag: Tag)
}
