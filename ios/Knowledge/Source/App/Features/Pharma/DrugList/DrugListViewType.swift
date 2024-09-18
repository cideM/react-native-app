//
//  DrugListViewType.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 08.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

/// @mockable
protocol DrugListViewType: AnyObject {
    func setApplicationForms(_ applicationForms: [TagButton.ViewData])
    func updateDrugList(drugs: [DrugReferenceViewData])
    func showIsLoading(_ isLoading: Bool)
}
