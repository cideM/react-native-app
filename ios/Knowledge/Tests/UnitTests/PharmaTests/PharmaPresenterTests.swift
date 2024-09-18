//
//  PharmaPresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 28.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import RichTextRenderer
import XCTest

class PharmaPresenterTests: XCTestCase {

    private var presenter: PharmaPresenterType!
    private var pharmaRepository: PharmaRepositoryTypeMock!
    private var coordinator: PharmaCoordinatorTypeMock!
    private var pharmaCoordinator: PharmaCoordinator!
    private var snippetRepository: SnippetRepositoryTypeMock!
    private var userDataRepository: UserDataRepositoryTypeMock!
    private var supportApplicationService: SupportApplicationServiceMock!
    private var supportApplicationServiceForDrug: SupportApplicationServiceMock!
    private var trackingProvider: TrackingTypeMock!
    private var view: PharmaViewTypeMock!

    override func setUp() {
        view = PharmaViewTypeMock()
        pharmaRepository = PharmaRepositoryTypeMock()
        coordinator = PharmaCoordinatorTypeMock()
        snippetRepository = SnippetRepositoryTypeMock()
        userDataRepository = UserDataRepositoryTypeMock()
        trackingProvider = TrackingTypeMock()
        supportApplicationService = SupportApplicationServiceMock()

        presenter = PharmaPresenter(
            coordinator: coordinator,
            pharmaRepository: pharmaRepository,
            remoteConfigRepository: RemoteConfigRepositoryTypeMock(),
            pharmaCardDeepLink: .fixture(),
            snippetRepository: snippetRepository,
            userDataRepository: userDataRepository,
            trackingProvider: trackingProvider,
            pharmaService: PharmaDatabaseApplicationServiceTypeMock(),
            supportApplicationService: supportApplicationService)
    }

    func testThatOnViewDidSetHealthCareProfessionDisclaimerIsShownOnTheViewIfHealthCareProfessionDisclaimerIsNotConfirmed() {
        userDataRepository.hasConfirmedHealthCareProfession = false

        XCTAssertEqual(view.showDisclaimerDialogCallCount, 0)

        presenter.view = view

        XCTAssertEqual(view.showDisclaimerDialogCallCount, 1)
    }

    func testThatOnViewDidSetPharmaCardDataIsPassedCorrectlyToTheViewIfHealthCareProfessionDisclaimerIsConfirmed() {
        let pharmaCard = PharmaCard.fixture()
        userDataRepository.hasConfirmedHealthCareProfession = true

        let pharmaCardExp = expectation(description: "Get pharmaCard function is called.")
        pharmaRepository.pharmaCardHandler = { _, _, _, _, completion in
            completion(.success((pharmaCard, .online)))
            pharmaCardExp.fulfill()
        }

        let exp = expectation(description: "Set data function is called.")
        view.setDataHandler = { result in
            XCTAssertEqual(pharmaCard.substance.name, result.title)
            if case let .drug(drugSectionViewData) = result.sections[1] {
                XCTAssertEqual(drugSectionViewData.title?.string, pharmaCard.drug.name)
                XCTAssertEqual(drugSectionViewData.activeIngredientGroupValue?.string, pharmaCard.drug.atcLabel)
            }

            exp.fulfill()
        }

        presenter.view = view
        wait(for: [pharmaCardExp, exp], timeout: 0.1)
    }

    func testThatOnViewDidSetDrugDataIsPassedCorrectlyToTheViewIfHealthCareProfessionDisclaimerIsConfirmed() {
        let pharmaCard = PharmaCard.fixture()
        let newDrug = Drug.fixture()
        userDataRepository.hasConfirmedHealthCareProfession = true

        let pharmaCardExp = expectation(description: "Get pharmaCard function is called.")
        pharmaRepository.pharmaCardHandler = { _, _, _, _, completion in
            completion(.success((pharmaCard, .online)))
            pharmaCardExp.fulfill()
        }

        // Load presenter with a pharmaCard
        presenter.view = view
        wait(for: [pharmaCardExp], timeout: 0.1)

        let drugExp = expectation(description: "Get drug function is called")
        pharmaRepository.drugHandler = { _, _, completion in
            completion(.success((newDrug, .online)))
            drugExp.fulfill()
        }

        let setEmptyDrugDataExp = expectation(description: "Set data function is called with no drug.")
        let setDrugDataExp = expectation(description: "Set data function is called with the right drug.")
        view.setDataHandler = { result in
            XCTAssertEqual(pharmaCard.substance.name, result.title)
            if result.sections.count == 1 {
                setEmptyDrugDataExp.fulfill()
            } else {
                if case let .drug(drugSectionViewData) = result.sections[1] {
                    XCTAssertEqual(drugSectionViewData.title?.string, newDrug.name)
                }
                setDrugDataExp.fulfill()
            }
        }

        self.presenter.switchDrug(to: newDrug.eid)
        wait(for: [setEmptyDrugDataExp, drugExp, setDrugDataExp], timeout: 0.2)
    }

    func testThatWhenLoadPharmaCardFailsTheViewReflectsItIfHealthCareProfessionDisclaimerIsConfirmed() {
        userDataRepository.hasConfirmedHealthCareProfession = true
        let pharmaCardExp = expectation(description: "Get pharmaCard function is called")
        pharmaRepository.pharmaCardHandler = { _, _, _, _, completion in
            completion(.failure(.noInternetConnection))
            pharmaCardExp.fulfill()
        }

        let exp = expectation(description: "Present message is called")
        view.presentSubviewMessageHandler = { _, _ in
            exp.fulfill()
        }

        presenter.view = view
        wait(for: [pharmaCardExp, exp], timeout: 0.1)
    }

    func testThatWhenLoadDrugFailsTheViewReflectsItIfHealthCareProfessionDisclaimerIsConfirmed() {
        let pharmaCard = PharmaCard.fixture()
        let newDrug = Drug.fixture()
        userDataRepository.hasConfirmedHealthCareProfession = true

        let pharmaCardExp = expectation(description: "Get pharmaCard function is called.")
        pharmaRepository.pharmaCardHandler = { _, _, _, _, completion in
            completion(.success((pharmaCard, .online)))
            pharmaCardExp.fulfill()
        }

        // Load presenter with a pharmaCard
        presenter.view = view
        wait(for: [pharmaCardExp], timeout: 0.1)

        let drugExp = expectation(description: "Get drug function is called")
        pharmaRepository.drugHandler = { _, _, completion in
            completion(.failure(.noInternetConnection))
            drugExp.fulfill()
        }

        let setEmptyDrugDataExp = expectation(description: "Set data function is called with no drug.")
        view.setDataHandler = { result in
            XCTAssertEqual(pharmaCard.substance.name, result.title)
            if result.sections.count == 1 {
                setEmptyDrugDataExp.fulfill()
            }
        }

        let exp = expectation(description: "Present message is called")
        view.presentSubviewMessageHandler = { _, _ in
            exp.fulfill()
        }

        self.presenter.switchDrug(to: newDrug.eid)
        wait(for: [setEmptyDrugDataExp, drugExp, exp], timeout: 0.2)
    }

    func testThatWhenDrugCallsSendFeedBackCoordinatorCallsSendFeedBack() {
        // Given
        XCTAssertEqual(coordinator.sendFeedbackCallCount, 0)

        // When
        presenter.sendFeedback()

        // Then
        XCTAssertEqual(coordinator.sendFeedbackCallCount, 1)
    }

    func testThatWhenDidTapPharmaRichTextLinkIsCalledWithAPhrasionaryDataSnippetRepositoryCallsSnippetForIdentifier() {
        // Given
        XCTAssertEqual(snippetRepository.snippetForCallCount, 0)

        // When
        presenter.didTapPharmaRichTextLink(phrasionary: .init(phraseGroupEid: .fixture()), ambossLink: .init(anchor: .fixture(), articleEid: .fixture(), linkType: .fixture(), uri: .fixture())  )

        // Then
        XCTAssertEqual(snippetRepository.snippetForCallCount, 1)
    }

    func testThatWhenDidTapPharmaRichTextLinkIsCalledWithAnEmptyPhrasionaryDataCoordinatorCallsNavigationToLearningCard() {
        // Given
        XCTAssertEqual(coordinator.navigateToCallCount, 0)
        let phrasionary: Phrasionary.Data? = nil

        // When
        presenter.didTapPharmaRichTextLink(phrasionary: phrasionary, ambossLink: .init(anchor: .fixture(), articleEid: .fixture(), linkType: .fixture(), uri: .fixture())  )

        // Then
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

        presenter.didTapPharmaRichTextLink(phrasionary: phrasionary, ambossLink: .init(anchor: .fixture(), articleEid: articleId, linkType: .fixture(), uri: .fixture())  )

        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenOtherPreperationsClicked() {
        let exp = expectation(description: "trackingProvider was called")

        let pharmaCard = PharmaCard.fixture()
        userDataRepository.hasConfirmedHealthCareProfession = true

        let exp1 = expectation(description: "Load Agent is called")
        pharmaRepository.pharmaCardHandler = { _, _, _, _, completion in
            completion(.success((pharmaCard, .online)))
            exp1.fulfill()
        }

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

        presenter.view = view
        presenter.otherPreparationsTapped()

        wait(for: [exp, exp1], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenPharmaCardClose() {
        let exp = expectation(description: "trackingProvider was called")

        let pharmaCard = PharmaCard.fixture()
        userDataRepository.hasConfirmedHealthCareProfession = true

        let pharmaCardExp = expectation(description: "Load pharmaCard is called")
        pharmaRepository.pharmaCardHandler = { _, _, _, _, completion in
            completion(.success((pharmaCard, .online)))
            pharmaCardExp.fulfill()
        }

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

        presenter.view = view
        presenter.viewDismissed()

        wait(for: [exp, pharmaCardExp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenPharmaFeedbackOpened() {
        let exp = expectation(description: "trackingProvider was called")

        let pharmaCard = PharmaCard.fixture()
        userDataRepository.hasConfirmedHealthCareProfession = true

        let pharmaCardExp = expectation(description: "Load pharmaCard is called")
        pharmaRepository.pharmaCardHandler = { _, _, _, _, completion in
            completion(.success((pharmaCard, .online)))
            pharmaCardExp.fulfill()
        }

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

        presenter.view = view
        presenter.sendFeedback()

        wait(for: [exp, pharmaCardExp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenPharmaCardShown() {
        let exp = expectation(description: "trackingProvider was called")

        let pharmaCard = PharmaCard.fixture()
        userDataRepository.hasConfirmedHealthCareProfession = true

        let pharmaCardExp = expectation(description: "Load pharmaCard is called")
        pharmaRepository.pharmaCardHandler = { _, _, _, _, completion in
            completion(.success((pharmaCard, .online)))
            pharmaCardExp.fulfill()
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .pharma(let event):
                switch event {
                case .pharmaAmbossSubstanceOpned(let ambossSubstanceId, let ambossSubstanceTitle, let brandedDrugId, let brandedDrugTitle, _, let datasource):
                    XCTAssertEqual(pharmaCard.substance.name, ambossSubstanceTitle)
                    XCTAssertEqual(pharmaCard.substance.id.value, ambossSubstanceId)
                    XCTAssertEqual(pharmaCard.drug.name, brandedDrugTitle)
                    XCTAssertEqual(pharmaCard.drug.eid.value, brandedDrugId)
                    XCTAssertEqual(DataSource.online, datasource)
                    exp.fulfill()
                default:
                    break
                }
            default:
                XCTFail()
            }
        }

        presenter.view = view
        presenter.viewDidAppear()

        wait(for: [exp, pharmaCardExp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenAFeedBackSent() {
        let exp = expectation(description: "trackingProvider was called")

        let pharmaCard = PharmaCard.fixture()
        userDataRepository.hasConfirmedHealthCareProfession = true

        let pharmaCardExp = expectation(description: "Load pharmaCard is called")
        pharmaRepository.pharmaCardHandler = { _, _, _, _, completion in
            completion(.success((pharmaCard, .online)))
            pharmaCardExp.fulfill()
        }

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

        presenter.view = view

        guard let delegate = presenter as? SupportApplicationServiceDelegate else {
            XCTFail("Downcase to SupportApplicationServiceDelegate failed")
            return
        }
        delegate.feedbackSubmitted(feedbackText: feedbackTextFixture)

        wait(for: [exp, pharmaCardExp], timeout: 0.1)
    }

}
