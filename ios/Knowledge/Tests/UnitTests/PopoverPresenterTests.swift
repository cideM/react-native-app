//
//  PopoverPresenterTests.swift
//  KnowledgeTests
//
//  Created by CSH on 14.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import XCTest

class PopoverPresenterTests: XCTestCase {

    var learningCardCoordinator: LearningCardCoordinatorTypeMock!
    var document: HtmlDocument!
    var galleryRepository: GalleryRepositoryTypeMock!
    var popoverPresenter: PopoverPresenter!
    var tracker: LearningCardTracker!
    var trackingProvider: TrackingTypeMock!
    var learningCardStack = PointableStack<LearningCardDeeplink>()
    var htmlSizeCalculationService: HTMLContentSizeCalculatorTypeMock!
    var deeplink: LearningCardDeeplink!

    override func setUp() {
        learningCardCoordinator = LearningCardCoordinatorTypeMock()
        galleryRepository = GalleryRepositoryTypeMock()
        trackingProvider = TrackingTypeMock()
        htmlSizeCalculationService = HTMLContentSizeCalculatorTypeMock()
        deeplink = .fixture()
        document = .popoverDocument(.fixture())

        let library = LibraryTypeMock()
        let libraryRepository = LibraryRepositoryTypeMock(library: library, learningCardStack: PointableStack<LearningCardDeeplink>())
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink!.learningCard)

        library.learningCardMetaItemHandler = { _ in metaItem }
        learningCardStack.append(deeplink)

        tracker = LearningCardTracker(trackingProvider: trackingProvider,
                                      libraryRepository: libraryRepository,
                                      learningCardOptionsRepository: LearningCardOptionsRepositoryTypeMock(), learningCardStack: learningCardStack, userStage: .fixture())

        popoverPresenter = PopoverPresenter(coordinator: learningCardCoordinator,
                                            document: document,
                                            galleryRepository: galleryRepository,
                                            tracker: tracker,
                                            htmlSizeCalculationService: htmlSizeCalculationService)
    }

    func testThatItCallsTheLoadFunctionOnTheViewWithTheCorrectFileUrlAndPath() {
        let view = PopoverViewTypeMock()
        let expectation = self.expectation(description: "load is called")
        view.loadHandler = { document in
            XCTAssertEqual(self.document, document)
            expectation.fulfill()
        }

        popoverPresenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatItPassesOpenLearningCardEventsToTheCoordinator() {
        let learningCardDeeplink = LearningCardDeeplink.fixture()

        let expectation = self.expectation(description: "navigate to deeplink is called")
        learningCardCoordinator.navigateHandler = { deeplink, _, _ in
            XCTAssertEqual(deeplink.learningCard, learningCardDeeplink.learningCard)
            XCTAssertEqual(deeplink.anchor, learningCardDeeplink.anchor)
            XCTAssertEqual(deeplink.sourceAnchor, learningCardDeeplink.sourceAnchor)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: popoverPresenter)
        popoverPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .openLearningCard(learningCardDeeplink))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatASnippetViewCanBePresentedFromThePopoverPresenterWithTheCorrectParameters() {
        let learningCardDeeplink = LearningCardDeeplink.fixture()

        let expectation = self.expectation(description: "navigate to deeplink is called")
        learningCardCoordinator.navigateHandler = { _, snippetAllowed, shouldPopToRoot in
            XCTAssertTrue(snippetAllowed)
            XCTAssertFalse(shouldPopToRoot)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: popoverPresenter)
        popoverPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .openLearningCard(learningCardDeeplink))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatItCallsOpenURLInternallyOnCoordinatorWhenOpenURLIsCalled() {
        let expectation = self.expectation(description: "open url internally")
        let expectedURL = URL(string: "https://www.amboss.com")!
        learningCardCoordinator.openURLInternallyHandler = { url in
            XCTAssertEqual(url, expectedURL)
            expectation.fulfill()
        }

        XCTAssertEqual(learningCardCoordinator.openURLInternallyCallCount, 0)
        popoverPresenter.openURL(expectedURL)
        XCTAssertEqual(learningCardCoordinator.openURLInternallyCallCount, 1)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingOnAnImageThatHasPrimaryExternalAdditionShowsExternalMediaInWebViewDirectly() {

        galleryRepository.primaryExternalAdditionHandler = { _ in ExternalAddition.fixture() }

        let galleryDeeplink = GalleryDeeplink.fixture()
        let bridge = WebViewBridge(delegate: popoverPresenter) // -> "bridge" is not used anywhere
        popoverPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .showImageGallery(galleryDeeplink))

        XCTAssertEqual(learningCardCoordinator.navigateToTrackerCallCount, 1)
        XCTAssertEqual(learningCardCoordinator.showImageGalleryCallCount, 0)
    }

    func testThatTappingOnAnImageThatHasNoPrimaryExternalAdditionShowsTheGallery() {

        galleryRepository.primaryExternalAdditionHandler = { _ in nil }

        let galleryDeeplink = GalleryDeeplink.fixture()
        let bridge = WebViewBridge(delegate: popoverPresenter) // -> "bridge" is not used anywhere
        popoverPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .showImageGallery(galleryDeeplink))

        XCTAssertEqual(learningCardCoordinator.navigateToCallCount, 0)
        XCTAssertEqual(learningCardCoordinator.showImageGalleryCallCount, 1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenAnotherLearningCardIsSelectedFromCurrentLearningCard() {

        let exp = expectation(description: "`.articleSelected` event was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleSelected(let article, let referrer):
                    XCTAssertEqual(self.deeplink.learningCard.value, article)
                    XCTAssertEqual(referrer, .article)
                    exp.fulfill()
                default: XCTFail()
                }
            default: XCTFail()
            }
        }

        let view = PopoverViewTypeMock()
        popoverPresenter.view = view
        let bridge = WebViewBridge(delegate: popoverPresenter)
        popoverPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .openLearningCard(deeplink))

        wait(for: [exp], timeout: 0.1)
    }
}
