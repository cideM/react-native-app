//
//  ListCoordinatorType.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 30.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain

/// @mockable
protocol ListCoordinatorType: Coordinator {
    func navigate(to learningCard: LearningCardDeeplink)
}
