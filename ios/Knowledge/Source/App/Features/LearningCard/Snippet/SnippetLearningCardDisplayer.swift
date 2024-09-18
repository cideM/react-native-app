//
//  SnippetLearningCardDisplayer.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 15.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
/*
 This is for navigation from a snippet view to a learning card.
*/

/// @mockable
protocol SnippetLearningCardDisplayer: AnyObject {
    func navigate(to deeplink: LearningCardDeeplink, shouldPopToRoot: Bool)
}
