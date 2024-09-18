//
//  AboutPresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 24.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class AboutPresenterTests: XCTestCase {

    var presenter: AboutPresenterType!
    var view: AboutViewTypeMock!
    var coordinator: SettingsCoordinatorTypeMock!
    var consentApplicationService: ConsentApplicationServiceTypeMock!

    override func setUp() {
        coordinator = SettingsCoordinatorTypeMock()
        consentApplicationService = ConsentApplicationServiceTypeMock()
        presenter = AboutPresenter(coordinator: coordinator, consentApplicationService: consentApplicationService)
        view = AboutViewTypeMock()
    }

    func testThatPresenterSetsViewDataOnViewDidSet() {
        let expectation = self.expectation(description: "view setData is called")
        view.setDataHandler = { _ in
            expectation.fulfill()
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenAnItemIsSelectedThenThePresenterCallsTheCoordinatorWithTheCorrectType() {
        let item = AboutViewItem(type: .legal)

        presenter.view = view

        let expectation = self.expectation(description: "coordinator openInAppURL is called")
        coordinator.openInAppHandler = { url in
            XCTAssertEqual(AppConfiguration.shared.legalNoticeURL, url)
            expectation.fulfill()
        }

        presenter.didSelect(item: item)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenTheConsentManagementItemIsSelectedThenThePresenterAsksConsentServiceToShowTheConsentDialog() {
        XCTAssertEqual(consentApplicationService.showConsentSettingsCallCount, 0)

        presenter.didSelect(item: AboutViewItem(type: .consentManagement))

        XCTAssertEqual(consentApplicationService.showConsentSettingsCallCount, 1)
    }

    func testThatWhenTheLibrariesItemIsSelectedThenThePresenterCallsTheCoordinatorToOpenLibrariesView() {
          let item = AboutViewItem(type: .libraries)

          presenter.view = view

          let expectation = self.expectation(description: "coordinator openLibrariesView is called")
          coordinator.openLibrariesViewHandler = {
              expectation.fulfill()
          }

          presenter.didSelect(item: item)
          wait(for: [expectation], timeout: 0.1)
      }

}
