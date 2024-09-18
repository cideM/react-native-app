//
//  MonographComponentPresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 15.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class MonographComponentWebViewPresenterTests: XCTestCase {

    var view: MonographComponentWebViewTypeMock!
    var presenter: MonographComponentWebViewPresenterType!
    var coordinator: MonographCoordinatorTypeMock!
    var monographComponent: MonographComponent!
    var snippetRepository: SnippetRepositoryTypeMock!
    var trackingProvider: TrackingTypeMock!
    var tracker: MonographPresenter.Tracker!

    override func setUp() {
        view = MonographComponentWebViewTypeMock()
        coordinator = MonographCoordinatorTypeMock()
        monographComponent = MonographComponent.references(title: "", htmlContent: "")
        snippetRepository = SnippetRepositoryTypeMock()
        trackingProvider = TrackingTypeMock()
        tracker = MonographPresenter.Tracker(trackingProvider: trackingProvider)
        presenter = MonographComponentWebViewPresenter(coordinator: coordinator, monographComponent: monographComponent, deeplink: .fixture(), snippetRepository: snippetRepository, tracker: tracker)
    }

    func testThatWhenTheViewIsSetTheViewLoadsTheCorrectMonographComponent() {
        let monographComponentTitle = "References"
        let monographComponentContent = "<></>"
        monographComponent = MonographComponent.references(title: monographComponentTitle, htmlContent: monographComponentContent)

        let exp = expectation(description: "View load is called")
        view.loadHandler = { _ in
            switch self.monographComponent {
            case .references(let title, let htmlContent):
                XCTAssertEqual(title, monographComponentTitle)
                XCTAssertEqual(htmlContent, monographComponentContent)
                exp.fulfill()
            default:
                XCTFail()
            }
        }

        presenter.view = view
        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenDismissViewIsCalledTheCoordinatorDismissesTheView() {
        let monographComponentTitle = "References"
        let monographComponentContent = "<></>"
        monographComponent = MonographComponent.references(title: monographComponentTitle, htmlContent: monographComponentContent)
        presenter.view = view

        let exp = expectation(description: "Coordinator dismiss view is called")
        coordinator.dismissViewHandler = {
            exp.fulfill()
        }

        presenter.dismissView()
        wait(for: [exp], timeout: 0.1)
    }
}
