//
//  TableDetailPresenterTests.swift
//  KnowledgeTests
//
//  Created by CSH on 04.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import XCTest

class TableDetailPresenterTests: XCTestCase {

    var coordinator: LearningCardCoordinatorTypeMock!
    var htmlDocument: HtmlDocument!
    var optionsRepository: LearningCardOptionsRepositoryTypeMock!
    var tableDetailPresenter: TableDetailPresenter!
    var galleryRepository: GalleryRepositoryTypeMock!
    var tracker: LearningCardTracker!
    var trackingProvider: TrackingTypeMock!
    var learningCardStack = PointableStack<LearningCardDeeplink>()
    var htmlSizeCalculationService: HTMLContentSizeCalculatorTypeMock!
    var deeplink: LearningCardDeeplink!

    override func setUp() {
        coordinator = LearningCardCoordinatorTypeMock()
        htmlDocument = .tableDocument(.fixture())
        optionsRepository = LearningCardOptionsRepositoryTypeMock()
        galleryRepository = GalleryRepositoryTypeMock()
        trackingProvider = TrackingTypeMock()
        htmlSizeCalculationService = HTMLContentSizeCalculatorTypeMock()

        let learnincCard = LearningCardIdentifier.fixture()
        deeplink = .init(learningCard: learnincCard, anchor: nil, particle: nil, sourceAnchor: nil)

        let library = LibraryTypeMock()
        let libraryRepository = LibraryRepositoryTypeMock(library: library, learningCardStack: PointableStack<LearningCardDeeplink>())
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink!.learningCard)

        library.learningCardMetaItemHandler = { _ in metaItem }
        learningCardStack.append(deeplink)

        tracker = LearningCardTracker(trackingProvider: trackingProvider,
                                                libraryRepository: libraryRepository,
                                                learningCardOptionsRepository: LearningCardOptionsRepositoryTypeMock(), learningCardStack: learningCardStack, userStage: .fixture())

        tableDetailPresenter = TableDetailPresenter(coordinator: coordinator,
                                                    document: htmlDocument,
                                                    optionsRepository: optionsRepository,
                                                    galleryRepository: galleryRepository,
                                                    userDataRepository: UserDataRepositoryTypeMock(),
                                                    remoteConfigRepository: RemoteConfigRepositoryTypeMock(),
                                                    userDataClient: UserDataClientMock(),
                                                    tracker: tracker,
                                                    htmlSizeCalculationService: htmlSizeCalculationService)
    }

    func testThatItCallsTheLoadFunctionOnTheViewWithTheCorrectFileUrlAndPath() {
        let view = TableDetailViewTypeMock()
        let expectation = self.expectation(description: "load is called")
        view.loadHandler = { htmlDocument in
            XCTAssertEqual(self.htmlDocument, htmlDocument)
            expectation.fulfill()
        }

        tableDetailPresenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatItPassesOpenLearningCardEventsToTheCoordinator() {
        let learningCardDeeplink = LearningCardDeeplink.fixture()

        let expectation = self.expectation(description: "navigate to deeplink is called")
        coordinator.navigateHandler = { deeplink, _, _ in
            XCTAssertEqual(deeplink.learningCard, learningCardDeeplink.learningCard)
            XCTAssertEqual(deeplink.anchor, learningCardDeeplink.anchor)
            XCTAssertEqual(deeplink.sourceAnchor, learningCardDeeplink.sourceAnchor)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: tableDetailPresenter)
        tableDetailPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .openLearningCard(learningCardDeeplink))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatItPassesOpenLearningCardEventsToTheCoordinatorWithoutAskingItToPopToRoot() {
        let learningCardDeeplink = LearningCardDeeplink.fixture()

        let expectation = self.expectation(description: "navigate to deeplink is called")
        coordinator.navigateHandler = { _, _, shouldPopToRoot in
            XCTAssertFalse(shouldPopToRoot)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: tableDetailPresenter)
        tableDetailPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .openLearningCard(learningCardDeeplink))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatASnippetViewCanBePresentedFromTheTableViewPresenter() {
        let learningCardDeeplink = LearningCardDeeplink.fixture()

        let expectation = self.expectation(description: "navigate to deeplink is called")
        coordinator.navigateHandler = { _, snippetAllowed, _ in
            XCTAssertTrue(snippetAllowed)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: tableDetailPresenter)
        tableDetailPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .openLearningCard(learningCardDeeplink))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatItPassesShowPopoverCardEventsToTheCoordinator() {
        let expectedHtml = HtmlDocument(headerElements: .fixture(), bodyElements: .fixture())

        let expectedContentSize = CGSize(width: CGFloat(Float.fixture()), height: CGFloat(Float.fixture()))
        htmlSizeCalculationService.calculateSizeHandler = { _, _, completion in
            completion(expectedContentSize)
        }

        let expectation = self.expectation(description: "onShowPopover is called")
        coordinator.showPopoverHandler = { html, _, _ in
            XCTAssertEqual(html.asData, expectedHtml.asData)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: tableDetailPresenter)
        tableDetailPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .showPopover(expectedHtml, tooltipType: nil))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTheCoordinatorReceivesTheExpectedPopoverSizeWhenAskedToPresentPopovers() {
        let expectedHtml = HtmlDocument(headerElements: .fixture(), bodyElements: .fixture())

        let expectedContentSize = CGSize(width: CGFloat(Float.fixture()), height: CGFloat(Float.fixture()))
        htmlSizeCalculationService.calculateSizeHandler = { _, _, completion in
            completion(expectedContentSize)
        }

        let expectation = self.expectation(description: "onShowPopover is called")
        coordinator.showPopoverHandler = { _, _, size in
            XCTAssertEqual(size, expectedContentSize)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: tableDetailPresenter)
        tableDetailPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .showPopover(expectedHtml, tooltipType: nil))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingOnAnImageThatHasPrimaryExternalAdditionShowsExternalMediaInWebViewDirectly() {

        galleryRepository.primaryExternalAdditionHandler = { _ in ExternalAddition.fixture() }

        let galleryDeeplink = GalleryDeeplink.fixture()
        let bridge = WebViewBridge(delegate: tableDetailPresenter) // -> "bridge" is not used anywhere
        tableDetailPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .showImageGallery(galleryDeeplink))

        XCTAssertEqual(coordinator.navigateToTrackerCallCount, 1)
        XCTAssertEqual(coordinator.showImageGalleryCallCount, 0)
    }

    func testThatTappingOnAnImageThatHasNoPrimaryExternalAdditionShowsTheGallery() {

        galleryRepository.primaryExternalAdditionHandler = { _ in nil }

        let galleryDeeplink = GalleryDeeplink.fixture()
        let bridge = WebViewBridge(delegate: tableDetailPresenter) // -> "bridge" is not used anywhere
        tableDetailPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .showImageGallery(galleryDeeplink))

        XCTAssertEqual(coordinator.navigateToCallCount, 0)
        XCTAssertEqual(coordinator.showImageGalleryCallCount, 1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenAnotherLearningCardIsSelectedFromCurrentLearningCard() {

        let exp = expectation(description: "`.articleSelected` event was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleSelected(let article, let referrer):
                    XCTAssertEqual(self.deeplink!.learningCard.value, article)
                    XCTAssertEqual(referrer, .article)
                    exp.fulfill()
                default: XCTFail()
                }
            default: XCTFail()
            }
        }

        let bridge = WebViewBridge(delegate: tableDetailPresenter)
        tableDetailPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .openLearningCard(deeplink))

        wait(for: [exp], timeout: 0.1)
    }
}
