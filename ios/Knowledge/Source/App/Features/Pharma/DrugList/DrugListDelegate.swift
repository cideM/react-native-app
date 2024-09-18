//
//  DrugListDelegate.swift
//  Knowledge DE
//
//  Created by Manaf Alabd Alrahim on 12.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain

/// @mockable
protocol DrugListDelegate: AnyObject {
    func didSelect(drug: DrugIdentifier)
}
