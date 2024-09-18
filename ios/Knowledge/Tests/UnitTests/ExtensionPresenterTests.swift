//
//  ExtensionPresenterTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 21.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
import Common
import Foundation
import Domain
@testable import Knowledge_DE
import XCTest

class ExtensionPresenterTests: XCTestCase {

    var presenter: ExtensionPresenterType!
    var extensionRepository: ExtensionRepositoryTypeMock!
    var library: LibraryTypeMock!
    var libraryRepository: LibraryRepositoryTypeMock!
    var coordinator: ListCoordinatorTypeMock!
    var view: ExtensionViewTypeMock!
    var trackingProvider: TrackingTypeMock!

    override func setUp() {
        extensionRepository = ExtensionRepositoryTypeMock()
        library = LibraryTypeMock(metadata: .fixture())
        libraryRepository = LibraryRepositoryTypeMock(library: library, learningCardStack: PointableStack<LearningCardDeeplink>())
        coordinator = ListCoordinatorTypeMock()
        view = ExtensionViewTypeMock()
        trackingProvider = TrackingTypeMock()

        presenter = ExtensionPresenter(extensionRepository: extensionRepository, libraryRepository: libraryRepository, coordinator: coordinator, trackingProvider: trackingProvider)
    }

    func testThatWhenViewIsSetThenPresenterInitializesViewItemsSortedbyDate() {
        let extensions = [
            Extension.fixture(section: LearningCardSectionIdentifier.fixture(value: "spec_1"), updatedAt: Date(year: 2020, month: 1, day: 1), note: "Hello there"),
            Extension.fixture(section: LearningCardSectionIdentifier.fixture(value: "spec_2"), updatedAt: Date(year: 2020, month: 2, day: 1), note: "Hello there"),
            Extension.fixture(section: LearningCardSectionIdentifier.fixture(value: "spec_3"), updatedAt: Date(year: 2020, month: 3, day: 1), note: "Hello there")
        ]

        let extensionMetaData = [
            ExtensionMetadata(extensions[0]),
            ExtensionMetadata(extensions[1]),
            ExtensionMetadata(extensions[2])
        ]

        extensionRepository.extensionsMetaDataHandler = {
            extensionMetaData
        }

        extensionRepository.extensionForSectionHandler = { identifier in
            extensions.filter { $0.section == identifier }.first
        }

        library.learningCardMetaItemHandler = { _ in
            LearningCardMetaItem.fixture(learningCardIdentifier: LearningCardIdentifier.fixture(value: "spec_5"))
        }

        let expectation = self.expectation(description: "View setExtentionsHandler is called")

        view.setExtensionsHandler = { items in
            XCTAssertEqual(items.first?.ext?.section, extensionMetaData[2].section)
            expectation.fulfill()
        }

        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenItemIsSelectedThenPresenterCallsTheCoordinatorDeepLinkWithCorrectLearningCard() {
        presenter.view = view

        let extensions = [
            Extension.fixture(section: LearningCardSectionIdentifier.fixture(value: "spec_1"), updatedAt: Date(year: 2020, month: 1, day: 1), note: "Hello there")
        ]

        let extensionMetaData = [ExtensionMetadata(extensions[0])]

        extensionRepository.extensionsMetaDataHandler = {
            extensionMetaData
        }

        extensionRepository.extensionForSectionHandler = { _ in
            extensions[0]
        }

        library.learningCardMetaItemHandler = { _ in
            LearningCardMetaItem.fixture(learningCardIdentifier: LearningCardIdentifier.fixture(value: "spec_5"))
        }

        let expectation = self.expectation(description: "Coordinator goHandler is called")
        coordinator.navigateHandler = { deepLink in
            XCTAssertEqual(deepLink.learningCard, LearningCardIdentifier.fixture(value: "spec_5"))
            expectation.fulfill()
        }

        presenter.deepLink(to: LearningCardDeeplink(learningCard: LearningCardIdentifier.fixture(value: "spec_5"), anchor: nil, particle: nil, sourceAnchor: nil))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenAChangeHappensInTheExtensionRepositoryTheViewReflectsIt() {
        presenter.view = view

        let expectation = self.expectation(description: "View setExtensions is called")
        view.setExtensionsHandler = { _ in
            expectation.fulfill()
        }

        NotificationCenter.default.post(ExtensionsDidChangeNotification(oldValue: [], newValue: [ExtensionMetadata.fixture()]), sender: extensionRepository)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(view.setExtensionsCallCount, 2)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenSelectingAnArticle() {

        let exp = expectation(description: "Tracking provider is called")

        let deeplink: LearningCardDeeplink = .fixture()

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleSelected(let articleID, let referrer):
                    XCTAssertEqual(articleID, deeplink.learningCard.value)
                    XCTAssertEqual(referrer, .ownExtensions)
                    exp.fulfill()

                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        presenter.deepLink(to: deeplink)
        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenViewIsSetThenPresenterInitializesViewWithoutEmptyNoteItems() {
        let extensions = [
            Extension.fixture(),
            Extension.fixture(section: LearningCardSectionIdentifier.fixture(), updatedAt: .fixture(), note: "")
        ]

        let extensionMetaData = [
            ExtensionMetadata(extensions[0]),
            ExtensionMetadata(extensions[1])
        ]

        extensionRepository.extensionsMetaDataHandler = {
            extensionMetaData
        }

        extensionRepository.extensionForSectionHandler = { identifier in
            extensions.filter { $0.section == identifier }.first
        }

        let expectation = self.expectation(description: "View setExtentionsHandler is called")

        view.setExtensionsHandler = { items in
            XCTAssertEqual(items.count, 1)
            expectation.fulfill()
        }

        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatNotesAreRenderedWithTheCorrectAttributesToTheView() {
        let formattedNote = "<ol><li><strong>&nbsp; Note: &nbsp;</strong></li><li>Note 1</li></ol>"

        let extensions = [
            Extension.fixture(section: LearningCardSectionIdentifier.fixture(), updatedAt: .fixture(), note: formattedNote)
        ]

        let extensionMetaData = [
            ExtensionMetadata(extensions[0])
        ]

        extensionRepository.extensionsMetaDataHandler = {
            extensionMetaData
        }

        extensionRepository.extensionForSectionHandler = { _ in
            extensions[0]
        }

        let expectation = self.expectation(description: "View setExtentionsHandler is called")

        view.setExtensionsHandler = { extensionViewData in
            XCTAssertEqual(extensionViewData[0].ext?.note, formattedNote)
            expectation.fulfill()
        }

        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }
}
