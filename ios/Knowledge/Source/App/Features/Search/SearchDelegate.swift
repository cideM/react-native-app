//
//  SearchDelegate.swift
//  Knowledge
//
//  Created by Silvio Bulla on 24.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

/// @mockable
protocol SearchDelegate: AnyObject {
    func navigate(to learningCard: LearningCardDeeplink)
    func navigate(to pharmaCard: PharmaCardDeeplink)
    func navigate(to monograph: MonographDeeplink)
    func dismissSearchView(completion: (() -> Void)?)
}
