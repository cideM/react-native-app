//
//  SnippetTrackingProvider.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 22.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

/// @mockable
protocol SnippetTrackingProvider {
    func track(learningCard identifier: LearningCardIdentifier)
}
