//
//  DosagePopoverPresenterTests.swift
//  KnowledgeTests
//
//  Created by Roberto Seidenberg on 10.11.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import Networking
import XCTest

class DosagePopoverPresenterTests: XCTestCase {

    var presenter: DosagePopoverPresenterType!
    var learningCardCoordinator: LearningCardCoordinatorTypeMock!
    var libraryCoordinator: LibraryCoordinatorTypeMock!
    var libraryRepository: LibraryRepositoryTypeMock!
    var repository: PharmaRepositoryTypeMock!
    var trackingProvider: TrackingTypeMock!
    var learningCardStack: PointableStack<LearningCardDeeplink>!

    var learningCard: LearningCardIdentifier!
    var dosageID: DosageIdentifier!

    override func setUp() {
        learningCardCoordinator = LearningCardCoordinatorTypeMock()
        libraryCoordinator = LibraryCoordinatorTypeMock()
        let library = LibraryTypeMock()
        libraryRepository = LibraryRepositoryTypeMock(library: library, learningCardStack: PointableStack<LearningCardDeeplink>())
        repository = PharmaRepositoryTypeMock()
        trackingProvider = TrackingTypeMock()

        learningCard = Identifier.fixture()
        dosageID = Identifier.fixture()
        learningCardStack = PointableStack<LearningCardDeeplink>()
        learningCardStack.append(LearningCardDeeplink(learningCard: learningCard, anchor: nil, particle: nil, sourceAnchor: nil))

        library.learningCardMetaItemHandler = { _ in
            LearningCardMetaItem.fixture(learningCardIdentifier: self.learningCard)
        }

        let tracker = LearningCardTracker(trackingProvider: trackingProvider,
                                          libraryRepository: libraryRepository,
                                          learningCardOptionsRepository: LearningCardOptionsRepositoryTypeMock(),
                                          learningCardStack: learningCardStack,
                                          userStage: .fixture())

        presenter = DosagePopoverPresenter(libraryCoordinator: libraryCoordinator,
                                           learningCardCoordinator: learningCardCoordinator,
                                           pharmaRepository: repository,
                                           dosageIdentifier: dosageID,
                                           remoteConfigRepository: RemoteConfigRepositoryTypeMock(),
                                           tracker: tracker)
    }

    func testThat_presentingAPopover_withOnlineSource_sendsExpectedTrackingEvent() {

        let expectation = expectation(description: "Should send expected tracking event")

        repository.dosageHandler = { id, completion in
            let dosage = Dosage(id: id, html: .fixture(), ambossSubstanceLink: .fixture())
            completion(.success((dosage, .online)))
        }

        repository.substanceHandler = { id, _, completion in
            let agent = Substance(id: id, name: .fixture(), drugReferences: [], pocketCard: nil, basedOn: .fixture())
            completion(.success((agent, .online)))
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .pharmaDosageShown(let articleID, let dosageID, let database):
                    XCTAssertEqual(articleID, self.learningCard.value)
                    XCTAssertEqual(dosageID, self.dosageID.value)
                    XCTAssertEqual(database, .online)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event type")
                }
            default:
                XCTFail("Unexpected event type")
            }
        }

        presenter.view = DosagePopoverViewTypeMock()
        wait(for: [expectation], timeout: 0.1)
    }

    func testThat_presentingAPopover_withOfflineSource_sendsExpectedTrackingEvent() {

        let expectation = expectation(description: "Should send expected tracking event")

        repository.dosageHandler = { id, completion in
            let dosage = Dosage(id: id, html: .fixture(), ambossSubstanceLink: .fixture())
            completion(.success((dosage, .offline)))
        }

        repository.substanceHandler = { id, _, completion in
            let agent = Substance(id: id, name: .fixture(), drugReferences: [], pocketCard: nil, basedOn: .fixture())
            completion(.success((agent, .offline)))
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .pharmaDosageShown(let articleID, let dosageID, let database):
                    XCTAssertEqual(articleID, self.learningCard.value)
                    XCTAssertEqual(dosageID, self.dosageID.value)
                    XCTAssertEqual(database, .offline)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event type")
                }
            default:
                XCTFail("Unexpected event type")
            }
        }

        presenter.view = DosagePopoverViewTypeMock()
        wait(for: [expectation], timeout: 0.1)
    }

    func testThat_presentingAPopover_withAnError_sendsExpectedTrackingEvent() {

        let expectation = expectation(description: "Should send expected tracking event")

        repository.dosageHandler = { _, completion in
            completion(.failure(.noInternetConnection))
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleDosageOpenFailed(let articleID, let dosageID, let error):
                    XCTAssertEqual(articleID, self.learningCard.value)
                    XCTAssertEqual(dosageID, self.dosageID.value)
                    XCTAssertEqual(error, String(describing: NetworkError<EmptyAPIError>.noInternetConnection))
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event type")
                }
            default:
                XCTFail("Unexpected event type")
            }
        }

        presenter.view = DosagePopoverViewTypeMock()
        wait(for: [expectation], timeout: 0.1)
    }
}
