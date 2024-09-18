//
//  PricesAndPackagesPresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 20.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class PricesAndPackagesPresenterTests: XCTestCase {

    var presenter: PricesAndPackagesPresenter!
    var view: PriceAndPackageViewTypeMock!
    var coordinator: PharmaCoordinatorTypeMock!

    override func setUp() {
        view = PriceAndPackageViewTypeMock()
        coordinator = PharmaCoordinatorTypeMock()
        presenter = PricesAndPackagesPresenter(coordinator: coordinator, data: [])
    }

    func testThatSettingTheViewLoadsTheCorrectDataOnTheView() {
        let pricesAndPackages: [PriceAndPackage] = .fixture()

        let exp = expectation(description: "Load data was called")

        view.loadHandler = { data in
            XCTAssertEqual(data.count, pricesAndPackages.count)
            exp.fulfill()
        }

        presenter.view = view
        wait(for: [exp], timeout: 0.1)
    }

    func testThatCallingDismissViewCallsTheRightMethodInTheCoordinator() {
        XCTAssertEqual(coordinator.dismissPricesAndPackagesViewCallCount, 0)

        presenter.dismissView()

        XCTAssertEqual(coordinator.dismissPricesAndPackagesViewCallCount, 1)
    }
}
