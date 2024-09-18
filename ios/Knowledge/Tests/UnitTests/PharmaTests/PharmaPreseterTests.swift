//
//  PharmaPreseterTests.swift
//  UnitTests
//
//  Created by Roberto Seidenberg on 19.07.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import RichTextRenderer
@testable import Knowledge_DE
import XCTest

class PharmaPresenterTests: XCTestCase {

    private var presenter: PharmaPresenterType!

    private var coordinator: PharmaCoordinatorTypeMock!
    private var pharmaRepository: PharmaRepositoryTypeMock!
    private var pharmaCoordinator: PharmaCoordinatorTypeMock!
    private var remoteConfigRepository: RemoteConfigRepositoryTypeMock!
    private var userDataRepository: UserDataRepositoryTypeMock!
    private var appConfiguration: ConfigurationMock!
    private var tracker: PharmaPagePresenter.Tracker!
    private var pharmaService: PharmaDatabaseApplicationServiceTypeMock!
    private var suportApplicationService: SupportApplicationServiceMock!

    private var trackingProvider: TrackingTypeMock!
    private var delegate: PharmaPresenterDelegateMock!

    override func setUp() {

        trackingProvider = TrackingTypeMock()
        tracker = PharmaPagePresenter.Tracker(trackingProvider: trackingProvider)
        tracker.source = .online

        coordinator = PharmaCoordinatorTypeMock()
        pharmaRepository = PharmaRepositoryTypeMock()
        pharmaCoordinator = PharmaCoordinatorTypeMock()
        remoteConfigRepository = RemoteConfigRepositoryTypeMock()
        userDataRepository = UserDataRepositoryTypeMock()
        appConfiguration = ConfigurationMock()
        pharmaService = PharmaDatabaseApplicationServiceTypeMock()
        suportApplicationService = SupportApplicationServiceMock()

        presenter = PharmaPresenter(
            coordinator: coordinator,
            pharmaRepository: pharmaRepository,
            remoteConfigRepository: remoteConfigRepository,
            userDataRepository: userDataRepository,
            appConfiguration: appConfiguration,
            pharmaService: pharmaService,
            supportApplicationService: suportApplicationService)

        presenter.tracker = tracker
        delegate = PharmaPresenterDelegateMock()
        presenter.delegate = delegate
    }

    func testThatWhenDrugCallsSendFeedBackCoordinatorCallsSendFeedBack() {
        XCTAssertEqual(coordinator.sendFeedbackCallCount, 0)
        presenter.sendFeedback()
        XCTAssertEqual(coordinator.sendFeedbackCallCount, 1)
    }

    func testThatWhenDidTapPharmaRichTextLinkIsCalledWithAPhrasionaryDataSnippetRepositoryCallsSnippetForIdentifier() {
        XCTAssertEqual(delegate.shouldShowSnippetCallCount, 0)
        presenter.didTapPharmaRichTextLink(phrasionary: .init(phraseGroupEid: .fixture()), ambossLink: .init(anchor: .fixture(), articleEid: .fixture(), linkType: .fixture(), uri: .fixture())  )
        XCTAssertEqual(delegate.shouldShowSnippetCallCount, 1)
    }

    func testThatWhenDidTapPharmaRichTextLinkIsCalledWithAnEmptyPhrasionaryDataCoordinatorCallsNavigationToLearningCard() {
        XCTAssertEqual(coordinator.navigateToCallCount, 0)
        let phrasionary: Phrasionary.Data? = nil
        presenter.didTapPharmaRichTextLink(phrasionary: phrasionary, ambossLink: .init(anchor: .fixture(), articleEid: .fixture(), linkType: .fixture(), uri: .fixture())  )
        XCTAssertEqual(coordinator.navigateToCallCount, 1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenNavigationToLearningCard() {
        let exp = expectation(description: "trackingProvider was called")
        let phrasionary: Phrasionary.Data? = nil
        let articleId: String = .fixture()

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleSelected(let articleID, let referrer):
                    XCTAssertEqual(articleID, articleId)
                    XCTAssertEqual(referrer, .pharmaCard)
                    exp.fulfill()
                default:
                    break
                }
            default:
                XCTFail()
            }
        }

        presenter.didTapPharmaRichTextLink(
            phrasionary: phrasionary,
            ambossLink: .init(anchor: .fixture(),
                              articleEid: articleId,
                              linkType: .fixture(),
                              uri: .fixture())
        )
        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenOtherPreperationsClicked() {
        let exp = expectation(description: "trackingProvider was called")

        let pharmaCard = PharmaCard.fixture()
        let data = PharmaPagePresenter.CardData(
            title: pharmaCard.drug.name,
            identifier: pharmaCard.drug.eid.value,
            substanceTitle: pharmaCard.substance.name,
            substanceIdentifier: pharmaCard.substance.id.value,
            riskInformation: false)
        tracker.fillCardDataOfCard(cardData: data)

        trackingProvider.trackHandler = { event in
            switch event {
            case .pharma(let event):
                switch event {
                case .availableDrugsOpened(let pharmaSubstanceTitle, let pharmaSubstanceId, let pharmaCardTitle, let pharmaCardXid, let pharmaType, let database):
                    XCTAssertEqual(pharmaCard.substance.name, pharmaSubstanceTitle)
                    XCTAssertEqual(pharmaCard.substance.id.value, pharmaSubstanceId)
                    XCTAssertEqual(pharmaCard.drug.name, pharmaCardTitle)
                    XCTAssertEqual(pharmaCard.drug.eid.value, pharmaCardXid)
                    XCTAssertEqual(.drug, pharmaType)
                    XCTAssertEqual(DatabaseType.online, database)
                    exp.fulfill()
                default:
                    break
                }
            default:
                XCTFail()
            }
        }

        presenter.otherPreparationsTapped()
        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenPharmaCardClose() {
        let exp = expectation(description: "trackingProvider was called")

        let pharmaCard = PharmaCard.fixture()
        let data = PharmaPagePresenter.CardData(
            title: pharmaCard.drug.name,
            identifier: pharmaCard.drug.eid.value,
            substanceTitle: pharmaCard.substance.name,
            substanceIdentifier: pharmaCard.substance.id.value,
            riskInformation: false)
        tracker.fillCardDataOfCard(cardData: data)

        trackingProvider.trackHandler = { event in
            switch event {
            case .pharma(let event):
                switch event {
                case .pharmaCardClose(_, let pharmaSubstanceTitle, let pharmaSubstanceId, let pharmaCardTitle, let pharmaCardXid, let pharmaType, let database):
                    XCTAssertEqual(pharmaCard.substance.name, pharmaSubstanceTitle)
                    XCTAssertEqual(pharmaCard.substance.id.description, pharmaSubstanceId)
                    XCTAssertEqual(pharmaCard.drug.name, pharmaCardTitle)
                    XCTAssertEqual(pharmaCard.drug.eid.description, pharmaCardXid)
                    XCTAssertEqual(.drug, pharmaType)
                    XCTAssertEqual(DatabaseType.online, database)
                    exp.fulfill()
                default:
                    break
                }
            default:
                XCTFail()
            }
        }
        
        presenter.viewDismissed()
        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenPharmaFeedbackOpened() {
        let exp = expectation(description: "trackingProvider was called")

        let pharmaCard = PharmaCard.fixture()
        let data = PharmaPagePresenter.CardData(
            title: pharmaCard.drug.name,
            identifier: pharmaCard.drug.eid.value,
            substanceTitle: pharmaCard.substance.name,
            substanceIdentifier: pharmaCard.substance.id.value,
            riskInformation: false)
        tracker.fillCardDataOfCard(cardData: data)

        trackingProvider.trackHandler = { event in
            switch event {
            case .pharma(let event):
                switch event {
                case .pharmaFeedbackOpened(let pharmaSubstanceTitle, let pharmaSubstanceId, let pharmaCardTitle, let pharmaCardXid, let pharmaType, let database):
                    XCTAssertEqual(pharmaCard.substance.name, pharmaSubstanceTitle)
                    XCTAssertEqual(pharmaCard.substance.id.value, pharmaSubstanceId)
                    XCTAssertEqual(pharmaCard.drug.name, pharmaCardTitle)
                    XCTAssertEqual(pharmaCard.drug.eid.value, pharmaCardXid)
                    XCTAssertEqual(.drug, pharmaType)
                    XCTAssertEqual(DatabaseType.online, database)
                    exp.fulfill()
                default:
                    break
                }
            default:
                XCTFail()
            }
        }

        // presenter.view = view
        presenter.sendFeedback()

        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenAFeedBackSent() {
        let exp = expectation(description: "trackingProvider was called")

        let pharmaCard = PharmaCard.fixture()
        let data = PharmaPagePresenter.CardData(
            title: pharmaCard.drug.name,
            identifier: pharmaCard.drug.eid.value,
            substanceTitle: pharmaCard.substance.name,
            substanceIdentifier: pharmaCard.substance.id.value,
            riskInformation: false)
        tracker.fillCardDataOfCard(cardData: data)

        let feedbackTextFixture: String = .fixture()
        trackingProvider.trackHandler = { event in
            switch event {
            case .pharma(let event):
                switch event {
                case .pharmaFeedbackSubmitted(let feedbackText, let pharmaSubstanceTitle, let pharmaSubstanceId, let pharmaCardTitle, let pharmaCardXid, let pharmaType, let database):
                    XCTAssertEqual(feedbackText, feedbackTextFixture)
                    XCTAssertEqual(pharmaCard.substance.name, pharmaSubstanceTitle)
                    XCTAssertEqual(pharmaCard.substance.id.value, pharmaSubstanceId)
                    XCTAssertEqual(pharmaCard.drug.name, pharmaCardTitle)
                    XCTAssertEqual(pharmaCard.drug.eid.value, pharmaCardXid)
                    XCTAssertEqual(.drug, pharmaType)
                    XCTAssertEqual(DatabaseType.online, database)
                    exp.fulfill()
                default:
                    break
                }
            default:
                XCTFail()
            }
        }

        guard let delegate = presenter as? SupportApplicationServiceDelegate else {
            XCTFail("Downcase to SupportApplicationServiceDelegate failed")
            return
        }
        delegate.feedbackSubmitted(feedbackText: feedbackTextFixture)
        wait(for: [exp], timeout: 0.1)
    }

}
