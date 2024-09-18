//
//  SnippetPresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 17.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class SnippetPresenterTests: XCTestCase {

    var coordinator: SnippetLearningCardDisplayerMock!
    var snippet: Snippet!
    var snippetPresenter: SnippetPresenterType!
    var deeplink: Deeplink!

    override func setUp() {
        coordinator = SnippetLearningCardDisplayerMock()
        snippet = .some(.fixture())
        deeplink = .some(.fixture())
        snippetPresenter = SnippetPresenter(coordinator: coordinator, snippet: snippet, deeplink: deeplink, trackingProvider: SnippetTrackingProviderMock())
    }

    func testThatWeCanNavigateToTheCorrectLearningCardDestinationFromASnippet() {
        let exp = expectation(description: "Navigate to deeplink is called")
        let expectedDeeplink = LearningCardDeeplink.fixture()
        coordinator.navigateHandler = { deepLink, _ in
            XCTAssertEqual(deepLink.learningCard, expectedDeeplink.learningCard)
            XCTAssertEqual(deepLink.anchor, expectedDeeplink.anchor)

            exp.fulfill()
        }

        snippetPresenter.go(to: expectedDeeplink)
        wait(for: [exp], timeout: 0.1)
    }

    func testThatTheDataIsPassedCorrectlyToTheView() {
        let view = SnippetViewTypeMock()

        let expectation = self.expectation(description: "setViewData is called")
        view.setViewDataHandler = { snippet, deeplink in

            switch deeplink {
            case .pharmaCard:
                XCTAssertEqual(snippet.identifier, self.snippet.identifier)
            case .learningCard(let learningCardDeeplink):
                XCTAssertEqual(snippet.identifier, self.snippet.identifier)
                if case .learningCard(let deeplink) = self.deeplink {
                    XCTAssertEqual(learningCardDeeplink.sourceAnchor, deeplink.sourceAnchor)
                }
            default:
                break
            }
            expectation.fulfill()
        }

        snippetPresenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatPresenterAsksTheCoordinatorToPopAllControllersWhenTheSnippetButtonIsTapped() {
        let exp = expectation(description: "Navigate to deeplink is called")
        let deeplink = LearningCardDeeplink.fixture()
        coordinator.navigateHandler = { _, shouldPopToRoot in
            XCTAssertTrue(shouldPopToRoot)
            exp.fulfill()
        }

        snippetPresenter.go(to: deeplink)
        wait(for: [exp], timeout: 0.1)
    }
}
