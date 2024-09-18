//
//  RootPresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 11.12.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class RootPresenterTests: XCTestCase {

    var rootPresenter: RootPresenterType!
    var rootCoordinator: RootCoordinatorTypeMock!
    var deeplinkService: DeepLinkServiceTypeMock!
    var trackingProvider: TrackingTypeMock!

    override func setUp() {
        rootCoordinator = RootCoordinatorTypeMock()
        deeplinkService = DeepLinkServiceTypeMock()
        trackingProvider = TrackingTypeMock()
        rootPresenter = RootPresenter(coordinator: rootCoordinator,
                                      deepLinkService: deeplinkService,
                                      trackingProvider: trackingProvider)
    }

    func testDeferringOfDeepLinksWhenCoordinatorIsCreated() {
        XCTAssertTrue(deeplinkService.deferDeepLinks)
    }

    func testDeferringOfDeepLinksWhenCoordinatorStops() {
        rootPresenter.didStop()
        XCTAssertTrue(deeplinkService.deferDeepLinks)
    }

    func testNotDeferringOfDeepLinksWhenCoordinatorStops() {
        rootPresenter.didStart()
        XCTAssertFalse(deeplinkService.deferDeepLinks)
    }

    func testCoordinatorBeingNotifiedToNavigateToTheDeepLink() {
        let webpageURL = URL(string: "https://www.amboss.com/de/library#xid=bH0HKh&anker=Zf974d8cff01b469f038157cfd85da31c")!
        let deepLink = Deeplink(url: webpageURL)
        rootPresenter.didReceiveDeepLink(deepLink)
        XCTAssertEqual(rootCoordinator.navigateCallCount, 1)
    }

    func testThatTrackingProviderIsNotifiedWhenASiriShortcutSearchDeepLinkIsExecuted() {
        let expectation = self.expectation(description: "Tracking provider was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .siri(.searchSiriShortcutExecuted): break
            default: XCTFail("Unexpected event")
            }
            expectation.fulfill()
        }

        let siriShortcutDeepLink = Deeplink.search(nil, source: .siri)
        rootPresenter.didReceiveDeepLink(siriShortcutDeepLink)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTrackingProviderIsNotifiedWhenArticleDeepLinkIsExecuted() {
        let expectation = self.expectation(description: "Tracking provider was called")
        let learningCardDeeplink: LearningCardDeeplink = .fixture()
        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleSelected(let article, let referrer):
                    XCTAssertEqual(learningCardDeeplink.learningCard.value, article)
                    XCTAssertEqual(referrer, .deepLink)
                    expectation.fulfill()
                default: XCTFail()
                }
            default: XCTFail()
            }
        }
        rootPresenter.didReceiveDeepLink(Deeplink.learningCard(learningCardDeeplink))

        wait(for: [expectation], timeout: 0.1)
    }
}
