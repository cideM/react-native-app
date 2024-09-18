//
//  DrugListPresenterType.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 08.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

/// @mockable
protocol DrugListPresenterType {
    var view: DrugListViewType? { get set }
    var delegate: DrugListDelegate? { get set }

    func searchTriggered(with query: String, applicationForm: ApplicationForm)
    func navigate(to drug: DrugIdentifier, title: String)
}
