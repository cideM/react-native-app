//
//  GalleryImageViewPresenterTests.swift
//  KnowledgeTests
//
//  Created by Merve Kavaklioglu on 08.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Foundation
import Domain
@testable import Knowledge_DE
import XCTest

class GalleryImageViewPresenterTests: XCTestCase {

    var presenter: GalleryImageViewPresenter!
    var repository: GalleryImageRepositoryTypeMock!
    var coordinator: GalleryCoordinatorTypeMock!
    var tracker: LearningCardTracker!
    var view: GalleryImageViewTypeMock!
    var trackingProvider: TrackingTypeMock!
    var library: LibraryTypeMock!
    var libraryRepository: LibraryRepositoryTypeMock!
    var learningCardStack: PointableStack<LearningCardDeeplink>!

    override func setUp() {
        repository = GalleryImageRepositoryTypeMock()
        coordinator = GalleryCoordinatorTypeMock()
        trackingProvider = TrackingTypeMock()
        view = GalleryImageViewTypeMock()
        learningCardStack = PointableStack<LearningCardDeeplink>()
        library = LibraryTypeMock()
        libraryRepository = LibraryRepositoryTypeMock(library: library, learningCardStack: PointableStack<LearningCardDeeplink>())
        tracker = LearningCardTracker(trackingProvider: trackingProvider, libraryRepository: libraryRepository, learningCardOptionsRepository: LearningCardOptionsRepositoryTypeMock(), learningCardStack: learningCardStack, userStage: .fixture())

        presenter = GalleryImageViewPresenter(image: ImageResourceType.fixture(standardImages: [.fixture()]), repository: repository, coordinator: coordinator, tracker: tracker)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenImageOverlayIsToggledOn() {
        presenter.view = view

        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 1
        let metaItem = LearningCardMetaItem.fixture()
        library.learningCardMetaItemHandler = {_ in
            metaItem
        }
        let deeplink = LearningCardDeeplink.fixture(learningCard: metaItem.learningCardIdentifier, anchor: nil, sourceAnchor: nil, question: nil)
        learningCardStack.append(deeplink)

        trackingProvider.trackHandler = { event in
            switch event {
            case .media(let event):
                switch event {
                case .imageMediaviewerToggleOverlay(let articleId, let imageId, let toggleState):
                    XCTAssertEqual(imageId, self.presenter.image.imageResourceIdentifier.value)
                    XCTAssertEqual(articleId, deeplink.learningCard.description)
                    XCTAssertEqual(toggleState, .toggleOn)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        presenter.toggleImageOverlay()

        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenImageOverlayIsToggledOff() {
        presenter.view = view

        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 1
        let metaItem = LearningCardMetaItem.fixture()
        library.learningCardMetaItemHandler = {_ in
            metaItem
        }
        let deeplink = LearningCardDeeplink.fixture(learningCard: metaItem.learningCardIdentifier, anchor: nil, sourceAnchor: nil, question: nil)
        learningCardStack.append(deeplink)
        presenter.toggleImageOverlay()

        trackingProvider.trackHandler = { event in
            switch event {
            case .media(let event):
                switch event {
                case .imageMediaviewerToggleOverlay(let articleId, let imageId, let toggleState):
                    XCTAssertEqual(imageId, self.presenter.image.imageResourceIdentifier.value)
                    XCTAssertEqual(articleId, deeplink.learningCard.description)
                    XCTAssertEqual(toggleState, .toggleOff)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        presenter.toggleImageOverlay()

        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenSmartZoomIsOpened() {
        presenter.view = view

        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 1
        let metaItem = LearningCardMetaItem.fixture()
        library.learningCardMetaItemHandler = {_ in
            metaItem
        }
        let deeplink = LearningCardDeeplink.fixture(learningCard: metaItem.learningCardIdentifier, anchor: nil, sourceAnchor: nil, question: nil)
        learningCardStack.append(deeplink)

        trackingProvider.trackHandler = { event in
            switch event {
            case .media(let event):
                switch event {
                case .imageMediaviewerToggleSmartzoom(let articleId, let imageId, let toggleState):
                    XCTAssertEqual(imageId, self.presenter.image.imageResourceIdentifier.value)
                    XCTAssertEqual(articleId, deeplink.learningCard.description)
                    XCTAssertEqual(toggleState, .toggleOn)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        presenter.navigate(to: ExternalAddition.fixture(type: .smartzoom, isFree: true))
        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenSmartZoomIsClosed() {
        presenter.view = view

        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 1
        let metaItem = LearningCardMetaItem.fixture()
        library.learningCardMetaItemHandler = {_ in
            metaItem
        }
        let deeplink = LearningCardDeeplink.fixture(learningCard: metaItem.learningCardIdentifier, anchor: nil, sourceAnchor: nil, question: nil)
        learningCardStack.append(deeplink)
        presenter.navigate(to: ExternalAddition.fixture(type: .smartzoom, isFree: true))

        trackingProvider.trackHandler = { event in
            switch event {
            case .media(let event):
                switch event {
                case .imageMediaviewerToggleSmartzoom(let articleId, let imageId, let toggleState):
                    XCTAssertEqual(imageId, self.presenter.image.imageResourceIdentifier.value)
                    XCTAssertEqual(articleId, deeplink.learningCard.description)
                    XCTAssertEqual(toggleState, .toggleOff)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        tracker.trackCloseSmartZoom(imageID: self.presenter.image.imageResourceIdentifier)
        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenAnImageIsShown() {

        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 1
        let metaItem = LearningCardMetaItem.fixture()
        library.learningCardMetaItemHandler = {_ in
            metaItem
        }
        let deeplink = LearningCardDeeplink.fixture(learningCard: metaItem.learningCardIdentifier, anchor: nil, sourceAnchor: nil, question: nil)
        learningCardStack.append(deeplink)

        trackingProvider.trackHandler = { event in
            switch event {
            case .media(let event):
                switch event {
                case .imageMediaviewerWasShown(let articleId, let imageId, let media, _, let referrer):
                    let image = self.presenter.image
                    XCTAssertEqual(imageId, image.imageResourceIdentifier.value)
                    XCTAssertEqual(articleId, deeplink.learningCard.description)
                    XCTAssertEqual(media?.eid, image.imageResourceIdentifier.value)
                    XCTAssertEqual(media?.typeName, "MediaAsset")
                    XCTAssertEqual(media?.title, image.title)
                    XCTAssertEqual(referrer.articleEid, deeplink.learningCard.description)
                    XCTAssertEqual(referrer.type, "article")
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        presenter.view = view
        presenter.viewWillAppear()
        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenAnImageIsHidden() {
        presenter.view = view

        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 1
        let metaItem = LearningCardMetaItem.fixture()
        library.learningCardMetaItemHandler = {_ in
            metaItem
        }
        let deeplink = LearningCardDeeplink.fixture(learningCard: metaItem.learningCardIdentifier, anchor: nil, sourceAnchor: nil, question: nil)
        learningCardStack.append(deeplink)

        trackingProvider.trackHandler = { event in
            switch event {
            case .media(let event):
                switch event {
                case .imageMediaviewerWasHidden(let articleId, let imageId, let media, _, let referrer):
                    let image = self.presenter.image
                    XCTAssertEqual(imageId, image.imageResourceIdentifier.value)
                    XCTAssertEqual(articleId, deeplink.learningCard.description)
                    XCTAssertEqual(media?.eid, image.imageResourceIdentifier.value)
                    XCTAssertEqual(media?.typeName, "MediaAsset")
                    XCTAssertEqual(media?.title, image.title)
                    XCTAssertEqual(referrer.articleEid, deeplink.learningCard.description)
                    XCTAssertEqual(referrer.type, "article")
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        presenter.viewDidDisappear()

        wait(for: [exp], timeout: 0.1)
    }
}
