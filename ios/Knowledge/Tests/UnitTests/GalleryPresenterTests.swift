//
//  GalleryPresenterTests.swift
//  KnowledgeTests
//
//  Created by CSH on 06.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import XCTest

class GalleryPresenterTests: XCTestCase {

    var presenter: GalleryPresenter!
    var repository: GalleryRepositoryTypeMock!
    var coordinator: GalleryCoordinatorTypeMock!
    var tracker: LearningCardTracker!

    override func setUp() {
        repository = GalleryRepositoryTypeMock()
        coordinator = GalleryCoordinatorTypeMock()
        tracker = LearningCardTracker(trackingProvider: TrackingTypeMock(),
                                      libraryRepository: LibraryRepositoryTypeMock(),
                                      learningCardOptionsRepository: LearningCardOptionsRepositoryTypeMock(),
                                      learningCardStack: PointableStack<LearningCardDeeplink>(),
                                      userStage: .fixture())

        presenter = GalleryPresenter(repository: repository, coordinator: coordinator, tracker: tracker, learningCardTitle: nil)
    }

    func testThatGoToDeeplinkSetsTheImagesOnTheView() {
        let expectation = self.expectation(description: "setImages is called")
        let deeplink = GalleryDeeplink.fixture(gallery: .fixture(value: "spec_gallery-identifier"), imageOffset: 0)
        let view = GalleryViewTypeMock()
        presenter.view = view
        let imageResourceIdentifiers: [ImageResourceIdentifier] = [.fixture(value: "spec_identifier_1"), .fixture(value: "spec_identifier_2")]

        view.setImagePresentersHandler = { presenters in
            XCTAssertEqual(presenters.count, imageResourceIdentifiers.count)
            let expectedIdentifiers = imageResourceIdentifiers.map { $0.value }
            let foundIdentifiers = presenters.map { $0.image.title! }
            XCTAssertEqual(foundIdentifiers, expectedIdentifiers)
            expectation.fulfill()
        }
        repository.galleryHandler = {
            XCTAssertEqual($0.value, "spec_gallery-identifier")
            return Gallery.fixture(imageResourceIdentifiers: imageResourceIdentifiers)
        }
        repository.imageResourceHandler = { identifier in
            ImageResourceType.fixture(title: identifier.value)
        }

        presenter.go(to: deeplink)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatGoToDeeplinkFiltersOutTheImagesThatHavePlaceholdersAndSetsTheFilteredImagesOnTheView() {
        let expectation = self.expectation(description: "setImages is called")
        let deeplink = GalleryDeeplink.fixture(gallery: .fixture(value: "spec_gallery-identifier"), imageOffset: 0)
        let view = GalleryViewTypeMock()
        presenter.view = view
        let imageResourceIdentifiers: [ImageResourceIdentifier] = [.fixture(value: "spec_identifier_1"), .fixture(value: "spec_identifier_2")]

        view.setImagePresentersHandler = { presenters in
            XCTAssertEqual(presenters.count, 1)
            let foundIdentifiers = presenters.map { $0.image.imageResourceIdentifier }
            XCTAssertEqual(foundIdentifiers[0], imageResourceIdentifiers[1])
            expectation.fulfill()
        }
        repository.galleryHandler = {
            XCTAssertEqual($0.value, "spec_gallery-identifier")
            return Gallery.fixture(imageResourceIdentifiers: imageResourceIdentifiers)
        }
        repository.imageResourceHandler = { identifier in
            ImageResourceType.fixture(imageResourceIdentifier: identifier)
        }
        repository.hasPlaceholderImageHandler = { galleryDeeplink in
            galleryDeeplink.imageOffset == 0
        }

        presenter.go(to: deeplink)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatDuplicateImagesAreFilteredOutOfTheGalleryFirst() {
        let setImagesExpectation = self.expectation(description: "setImages is called")
        let goToImageExpectation = self.expectation(description: "goToImage is called")
        let deeplink = GalleryDeeplink.fixture(gallery: .fixture(value: "spec_gallery-identifier"), imageOffset: 2)
        let view = GalleryViewTypeMock()
        presenter.view = view
        let imageResourceIdentifiers: [ImageResourceIdentifier] = [.fixture(value: "spec_identifier_1"), .fixture(value: "spec_identifier_1"), .fixture(value: "spec_identifier_2")]

        view.setImagePresentersHandler = { presenters in
            XCTAssertEqual(presenters.count, 2)
            let foundIdentifiers = presenters.map { $0.image.imageResourceIdentifier }
            XCTAssertEqual(foundIdentifiers[0], imageResourceIdentifiers[0])
            XCTAssertEqual(foundIdentifiers[1], imageResourceIdentifiers[2])
            setImagesExpectation.fulfill()
        }
        view.goToImageHandler = { (index, animated) in
            XCTAssertEqual(index, 1)
            goToImageExpectation.fulfill()
        }
        repository.galleryHandler = {
            XCTAssertEqual($0.value, "spec_gallery-identifier")
            return Gallery.fixture(imageResourceIdentifiers: imageResourceIdentifiers)
        }
        repository.imageResourceHandler = { identifier in
            ImageResourceType.fixture(title: "", description: "", copyright: "", imageResourceIdentifier: identifier)
        }
        repository.hasPlaceholderImageHandler = { galleryDeeplink in false }

        presenter.go(to: deeplink)
        wait(for: [setImagesExpectation, goToImageExpectation], timeout: 0.1)
    }

    func testThatGoToDeeplinkNavigatesToTheCorrectImage() {
        let expectation = self.expectation(description: "go is called")
        let deeplink = GalleryDeeplink.fixture(gallery: .fixture(value: "spec_gallery-identifier"), imageOffset: 1)
        let view = GalleryViewTypeMock()
        presenter.view = view
        let imageResourceIdentifiers: [ImageResourceIdentifier] = [.fixture(value: "spec_identifier_1"), .fixture(value: "spec_identifier_2")]

        view.goToImageHandler = { index, _ in
            XCTAssertEqual(index, 1)
            expectation.fulfill()
        }
        repository.galleryHandler = { _ in
            Gallery.fixture(imageResourceIdentifiers: imageResourceIdentifiers)
        }
        repository.imageResourceHandler = { identifier in
            ImageResourceType.fixture(title: identifier.value)
        }

        presenter.go(to: deeplink)
        wait(for: [expectation], timeout: 0.1)
    }
}
