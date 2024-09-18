//
//  GalleryRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 01.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import XCTest

class GalleryRepositoryTests: XCTestCase {

    var library: LibraryTypeMock!
    var libraryRepository: LibraryRepositoryTypeMock!
    var mediaClient: MediaClientMock!
    var galleryRepository: GalleryRepositoryType!

    override func setUp() {
        library = LibraryTypeMock()
        libraryRepository = LibraryRepositoryTypeMock(library: library, learningCardStack: PointableStack<LearningCardDeeplink>())
        mediaClient = MediaClientMock()
        galleryRepository = GalleryRepository(libraryRepository: libraryRepository, mediaClient: mediaClient)
    }

    func testThatGalleryReturnsTheCorrectGallery() {
        let galleryToReturn: Gallery = .fixture()
        library.galleryHandler = { _ in
            galleryToReturn
        }

        let returnedGallery = try! galleryRepository.gallery(with: .fixture())

        XCTAssertEqual(galleryToReturn, returnedGallery)
    }

    func testThatImageResourceReturnsTheCorrectImageResource() {
        let imageResourceToReturn: ImageResourceType = .fixture()
        library.imageResourceHandler = { _ in
            imageResourceToReturn
        }

        let returnedImageResource = try! galleryRepository.imageResource(for: .fixture())

        XCTAssertEqual(imageResourceToReturn.imageResourceIdentifier, returnedImageResource.imageResourceIdentifier)
    }

    func testThatExternalAdditionsForImage_ReturnsTheCorrectExternalAdditions() {
        let externalAdditionsToReturn: [ExternalAddition] = .fixture()
        let imageResource: ImageResourceType = .fixture(externalAdditions: externalAdditionsToReturn)
        let gallery: Gallery = .fixture(id: .fixture(), imageResourceIdentifiers: [imageResource].map { $0.imageResourceIdentifier })
        library.galleryHandler = { _ in
            gallery
        }
        library.imageResourceHandler = { _ in
            imageResource
        }

        let returnedExternalAdditions = try! galleryRepository.externalAdditionsForImage(at: .fixture(gallery: gallery.id, imageOffset: 0))

        XCTAssertEqual(returnedExternalAdditions.count, externalAdditionsToReturn.count)
        zip(returnedExternalAdditions, externalAdditionsToReturn).forEach {
            XCTAssertEqual($0.0.identifier, $0.1.identifier)
            XCTAssertEqual($0.0.type, $0.1.type)
            XCTAssertEqual($0.0.isFree, $0.1.isFree)
        }
    }

    func testThat_HasPlaceholderImage_ReturnsFalseForAnImageResource_ThatHasMoreThanOneExternalAddition() {
        let externalAdditionsToReturn: [ExternalAddition] = .fixture()
        let imageResource: ImageResourceType = .fixture(externalAdditions: externalAdditionsToReturn)
        let gallery: Gallery = .fixture(id: .fixture(), imageResourceIdentifiers: [imageResource].map { $0.imageResourceIdentifier })
        library.galleryHandler = { _ in
            gallery
        }
        library.imageResourceHandler = { _ in
            imageResource
        }

        XCTAssertFalse(try! galleryRepository.hasPlaceholderImage(for: .fixture(gallery: gallery.id, imageOffset: 0)))
    }

    func testThatHasPlaceholderImage_ReturnsTrue_ForAnImageResource_ThatHasAnAssociatedFeatureInTheLibrary_ThatHasAPlaceholderImage() {
        let externalAdditionsToReturn: [ExternalAddition] = [.fixture(type: .meditricks)]
        let imageResource: ImageResourceType = .fixture(externalAdditions: externalAdditionsToReturn)
        let gallery: Gallery = .fixture(id: .fixture(), imageResourceIdentifiers: [imageResource].map { $0.imageResourceIdentifier })
        library.galleryHandler = { _ in
            gallery
        }
        library.imageResourceHandler = { _ in
            imageResource
        }

        XCTAssertTrue(try! galleryRepository.hasPlaceholderImage(for: .fixture(gallery: gallery.id, imageOffset: 0)))
    }

    func testThat_HasPlaceholderImage_ReturnsFalseForAnImageResource_ThatHasAnAssociatedFeatureInTheLibrary_ThatDoesNotHaveAPlaceholderImage() {
        let externalAdditionsToReturn: [ExternalAddition] = [.fixture(type: .smartzoom)]
        let imageResource: ImageResourceType = .fixture(externalAdditions: externalAdditionsToReturn)
        let gallery: Gallery = .fixture(id: .fixture(), imageResourceIdentifiers: [imageResource].map { $0.imageResourceIdentifier })
        library.galleryHandler = { _ in
            gallery
        }
        library.imageResourceHandler = { _ in
            imageResource
        }

        XCTAssertFalse(try! galleryRepository.hasPlaceholderImage(for: .fixture(gallery: gallery.id, imageOffset: 0)))
    }

    func testThat_AnImage_ThatHasOneFeatureAndAPlaceholder_ReturnsAnExternalAddition() {

        let externalAddition = ExternalAddition.fixture(type: .meditricksNeuroanatomy, isFree: true)
        let identifier = ImageResourceIdentifier.fixture()
        let imageResource = ImageResourceType.fixture(externalAdditions: [externalAddition], imageResourceIdentifier: identifier)
        let gallery = Gallery.fixture(id: .fixture(), imageResourceIdentifiers: [identifier])

        library.galleryHandler = { _ in gallery }
        library.imageResourceHandler = { _ in imageResource }

        let galleryDeeplink = GalleryDeeplink.fixture(gallery: gallery.id, imageOffset: 0)
        let key = galleryRepository.primaryExternalAddition(for: galleryDeeplink)

        XCTAssertEqual(library.imageResourceCallCount, 2)
        XCTAssertNotNil(key)
    }

    func testThat_AnImageThatHasOneFeatureAndNoPlaceholder_DoesNotReturnAnExternalAddition() {

        let externalAddition = ExternalAddition.fixture(type: .smartzoom, isFree: true)
        let identifier = ImageResourceIdentifier.fixture()
        let imageResource = ImageResourceType.fixture(externalAdditions: [externalAddition], imageResourceIdentifier: identifier)
        let gallery = Gallery.fixture(id: .fixture(), imageResourceIdentifiers: [identifier])

        library.galleryHandler = { _ in gallery }
        library.imageResourceHandler = { _ in imageResource }

        let galleryDeeplink = GalleryDeeplink.fixture(gallery: gallery.id, imageOffset: 0)
        let addition = galleryRepository.primaryExternalAddition(for: galleryDeeplink)

        XCTAssertEqual(library.imageResourceCallCount, 2)
        XCTAssertNil(addition)
    }

    func testThat_AnImageThatHasMutlipleFeatures_DoesNotReturnAnExternalAddition() {

        let externalAddition1 = ExternalAddition.fixture(type: .meditricksNeuroanatomy, isFree: true)
        let externalAddition2 = ExternalAddition.fixture(type: .miamed3dModel, isFree: true)
        let externalAddition3 = ExternalAddition.fixture(type: .miamedWebContent, isFree: true)

        let identifier = ImageResourceIdentifier.fixture()
        let imageResource = ImageResourceType.fixture(externalAdditions: [externalAddition1, externalAddition2, externalAddition3], imageResourceIdentifier: identifier)
        let gallery = Gallery.fixture(id: .fixture(), imageResourceIdentifiers: [identifier])

        library.galleryHandler = { _ in gallery }
        library.imageResourceHandler = { _ in imageResource }

        let galleryDeeplink = GalleryDeeplink.fixture(gallery: gallery.id, imageOffset: 0)
        let key = galleryRepository.primaryExternalAddition(for: galleryDeeplink)

        XCTAssertEqual(library.imageResourceCallCount, 2)
        XCTAssertNil(key)
    }
}
