//
//  PricesAndPackagesPresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 14.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

protocol PricesAndPackagesPresenterType: AnyObject {
    var view: PriceAndPackageViewType? { get set }

    func dismissView()
}

final class PricesAndPackagesPresenter: PricesAndPackagesPresenterType {

    private let data: [PriceAndPackage]

    private let coordinator: PharmaCoordinatorType

    weak var view: PriceAndPackageViewType? {
        didSet {
            view?.load(data: data)
        }
    }

    init(coordinator: PharmaCoordinatorType, data: [PriceAndPackage]) {
        self.coordinator = coordinator
        self.data = data
    }

    func dismissView() {
        coordinator.dismissPricesAndPackagesView()
    }
}
