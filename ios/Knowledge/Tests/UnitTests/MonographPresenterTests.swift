//
//  MonographPresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 21.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import XCTest

class MonographPresenterTests: XCTestCase {

    var view: MonographViewTypeMock!
    var presenter: MonographPresenterType!
    var coordinator: MonographCoordinatorTypeMock!
    var monographRepository: MonographRepositoryTypeMock!
    var snippetRepository: SnippetRepositoryTypeMock!
    var supportApplicationService: SupportApplicationServiceMock!
    var trackingProvider: TrackingTypeMock!
    var deeplink: MonographDeeplink!

    override func setUp() {
        view = MonographViewTypeMock()
        coordinator = MonographCoordinatorTypeMock()

        deeplink = MonographDeeplink(monograph: MonographIdentifier(value: "monograph"), anchor: .fixture())
        monographRepository = MonographRepositoryTypeMock()
        snippetRepository = SnippetRepositoryTypeMock()
        supportApplicationService = SupportApplicationServiceMock()
        trackingProvider = TrackingTypeMock()
        presenter = MonographPresenter(coordinator: coordinator, deeplink: deeplink, monographRepository: monographRepository, snippetRepository: snippetRepository, trackingProvider: trackingProvider, supportApplicationService: supportApplicationService)
    }

    func testThat_WhenEvent_monographLinkClicked_IsCalled_TheViewLoadsTheCorrectMonographHTML() {
        presenter.view = view

        let expectedMonograph = Monograph.fixture()
        monographRepository.monographHandler = { _, completion in
            completion(.success(expectedMonograph))
        }

        let expHTML = expectation(description: "View load HTML is called")
        view.updateHandler = { title, html, _ in
            XCTAssertEqual(title, expectedMonograph.title)
            XCTAssertEqual(html, expectedMonograph.html)
            expHTML.fulfill()
            self.presenter.bridge(didReceive: .initializeEnd) // <- usually called via webview
        }

        let expAnchor = expectation(description: "View load HTML is called")
        view.goHandler = { anchor in
            XCTAssertEqual(self.deeplink.anchor, anchor)
            expAnchor.fulfill()
        }

        presenter.bridge(didReceive: .openLinkToMonograph(deeplink))
        wait(for: [expHTML, expAnchor], timeout: 0.1)
    }

    func testThat_WhenEvent_ambossSnippetClicked_IsCalled_TheSnippetOverlayIsPresented() {
        presenter.view = view

        let snippet = Snippet.fixture()
        let snippetIdentifier = SnippetIdentifier(value: String.fixture())
        let exp = expectation(description: "Coordinator should present snippet overlay")

        snippetRepository.snippetForHandler = { snippetId, completion in
            XCTAssertEqual(snippetId.value, snippetIdentifier.value)
            completion(.success(snippet))
        }

        coordinator.showSnippetViewHandler = { snippet2, _ in
            XCTAssertEqual(snippet2.identifier.value, snippet.identifier.value)
            exp.fulfill()
        }

        presenter.bridge(didReceive: .openLinkToSnippet(snippet: snippetIdentifier))
        wait(for: [exp], timeout: 0.1)
    }

    func testThat_WhenEvent_tableClicked_IsCalled_TheTableScreenIsPresented() {
        presenter.view = view

        let expectedHTML = String.fixture()

        let exp = expectation(description: "Coordinator show monograph component is called")
        coordinator.showMonographComponentHandler = { monographComponent, _ in
            switch monographComponent {
            case .table(_, let htmlContent):
                XCTAssertEqual(htmlContent, expectedHTML)
                exp.fulfill()
            default: XCTFail()
            }
        }

        presenter.bridge(didReceive: .openTable(title: .fixture(), html: expectedHTML))

        XCTAssertEqual(coordinator.showMonographComponentCallCount, 1)
        wait(for: [exp], timeout: 0.1)
    }

    func testThat_WhenEvent_off_label_element_IsCalled_TheRightScreenIsPresented() {
        presenter.view = view

        let expectedHTML = String.fixture()

        let exp = expectation(description: "Coordinator show monograph component is called")
        coordinator.showMonographComponentHandler = { monographComponent, _ in
            switch monographComponent {
            case .offLabelElement(let htmlContent):
                XCTAssertEqual(htmlContent, expectedHTML)
                exp.fulfill()
            default: XCTFail()
            }
        }

        presenter.bridge(didReceive: .offLabelElementClicked(html: expectedHTML))

        XCTAssertEqual(coordinator.showMonographComponentCallCount, 1)
        wait(for: [exp], timeout: 0.1)
    }

    func testThat_WhenEvent_ambossLinkClicked_IsCalled_TheLearningCardScreenIsPresented() {
        presenter.view = view

        let expectedLearningCard = LearningCardDeeplink.fixture()

        coordinator.navigateToHandler = { learningCard in
            XCTAssertEqual(learningCard, expectedLearningCard)
        }

        presenter.bridge(didReceive: .openLinkToAmboss(learningCardDeeplink: expectedLearningCard))
        XCTAssertEqual(coordinator.navigateToCallCount, 1)
    }

    func testThat_WhenEvent_external_link_clicked_isCalled_TheWebpageIsPresented() {
        presenter.view = view

        let url = URL.fixture()

        coordinator.openURLInternallyHandler = { ur in
            XCTAssertEqual(ur, url)
        }

        presenter.bridge(didReceive: .openLinkToExternalPage(url: url))
        XCTAssertEqual(coordinator.openURLInternallyCallCount, 1)
    }

    func testThat_WhenWebViewDidFailToLoadIsCalledTheViewPresentsTheErrorView() {
        presenter.view = view

        let exp = expectation(description: "View showErrorView is called")
        view.showErrorHandler = { _, _ in
            exp.fulfill()
        }

        presenter.webViewDidFailToLoad()
        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingIsNotifiedWhenMonographIsShown() {
        let monograph = Monograph.fixture()

        let updateViewExp = expectation(description: "Update view is called")
        view.updateHandler = { title, html, _ in
            XCTAssertEqual(monograph.title, title)
            XCTAssertEqual(monograph.html, html)
            updateViewExp.fulfill()
        }

        let monographExp = expectation(description: "Load monograph is called")
        monographRepository.monographHandler = { _, completion in
            completion(.success(monograph))
            monographExp.fulfill()
        }

        let analitycsExp = expectation(description: "AnalyticsTrackingProvider is called with the correct event")
        trackingProvider.trackHandler = { event in
            switch event {
            case .monograph(let event):
                switch event {
                case .monographOpened(let monographTitle, let monographId, let databaseType):
                    XCTAssertEqual(monograph.title, monographTitle)
                    XCTAssertEqual(monograph.id.value, monographId)
                    XCTAssertEqual(databaseType, DatabaseType.online)
                    analitycsExp.fulfill()

                default: break
                }

            default:
                XCTFail("Trying to to track the wrong event")
            }
        }

        presenter.view = view
        wait(for: [updateViewExp, monographExp, analitycsExp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingIsNotifiedWhenTheBridgeReceivesAnAnalyticEvent() {
        let monograph = Monograph.fixture()
        let genericEventName = "generic_event_name"
        let eventProperties = ["generic_name": "generic_value"]

        let monographExp = expectation(description: "Load monograph is called")
        monographRepository.monographHandler = { _, completion in
            completion(.success(monograph))
            monographExp.fulfill()
        }

        let analitycsExp = expectation(description: "AnalyticsTrackingProvider is called with the correct event")
        trackingProvider.trackHandler = { event in
            switch event {
            case .monograph(let event):
                switch event {
                case .genericEvent(let eventName, let properties, _):
                    XCTAssertEqual(eventName, genericEventName)
                    XCTAssertEqual(properties["generic_name"] as? String, "generic_value")
                    analitycsExp.fulfill()
                default: break
                }

            default:
                XCTFail("Trying to to track the wrong event")
            }
        }

        presenter.view = view
        presenter.bridge(didReceive: .genericEvent(eventName: genericEventName, properties: eventProperties))
        wait(for: [monographExp, analitycsExp], timeout: 0.1)
    }
}
