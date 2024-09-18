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

class PharmaPagePresenterTests: XCTestCase {

    private var presenter: PharmaPagePresenterType!
    private var pharmaRepository: PharmaRepositoryTypeMock!
    private var coordinator: PharmaCoordinatorTypeMock!
    private var pharmaCoordinator: PharmaCoordinator!
    private var snippetRepository: SnippetRepositoryTypeMock!
    private var userDataRepository: UserDataRepositoryTypeMock!
    private var supportApplicationService: SupportApplicationServiceMock!
    private var supportApplicationServiceForDrug: SupportApplicationServiceMock!
    private var trackingProvider: TrackingTypeMock!
    private var tracker: PharmaPagePresenter.Tracker!

    private var view: PharmaPageViewTypeMock!

    private var pharmaPresenter: PharmaPresenterTypeMock!
    private var pharmaView: PharmaViewTypeMock!

    private var ifapPresenter: PharmaPresenterType!
    private var ifapView: PharmaViewTypeMock!

    override func setUp() {
        pharmaRepository = PharmaRepositoryTypeMock()
        coordinator = PharmaCoordinatorTypeMock()
        snippetRepository = SnippetRepositoryTypeMock()
        userDataRepository = UserDataRepositoryTypeMock()
        supportApplicationService = SupportApplicationServiceMock()

        trackingProvider = TrackingTypeMock()
        tracker = PharmaPagePresenter.Tracker(trackingProvider: trackingProvider)
        tracker.source = .online

        let pharmaPresenter = PharmaPresenterTypeMock()
        let pharmaView = PharmaViewTypeMock()

        ifapPresenter = PharmaPresenterTypeMock()
        ifapView = PharmaViewTypeMock()

        presenter = PharmaPagePresenter(
            coordinator: coordinator,
            userDataRepository: userDataRepository,
            pharmaRepository: pharmaRepository,
            pharmaCardDeepLink: .fixture(),
            snippetRepository: snippetRepository,
            tracker: tracker,
            ifap: (presenter: ifapPresenter, view: ifapView),
            pocketCard: (presenter: pharmaPresenter, view: pharmaView))

        view = PharmaPageViewTypeMock()
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenPharmaCardShown() {
        let trackerExp = expectation(description: "trackingProvider was called")

        let pharmaCard = PharmaCard.fixture()
        let data = PharmaPagePresenter.CardData(
            title: pharmaCard.drug.name,
            identifier: pharmaCard.drug.eid.value,
            substanceTitle: pharmaCard.substance.name,
            substanceIdentifier: pharmaCard.substance.id.value,
            riskInformation: false)
        tracker.fillCardDataOfCard(cardData: data)

        let pharmaCardExp = expectation(description: "Get pharmaCard function is called.")
        pharmaRepository.pharmaCardHandler = { _, _, _, _, completion in
            completion(.success((pharmaCard, .online)))
            pharmaCardExp.fulfill()
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .pharma(let event):
                switch event {
                case .pharmaAmbossSubstanceOpened(let ambossSubstanceId, let ambossSubstanceTitle, let brandedDrugId, let brandedDrugTitle, _, let datasource, let document, let group):
                    XCTAssertEqual(pharmaCard.substance.name, ambossSubstanceTitle)
                    XCTAssertEqual(pharmaCard.substance.id.value, ambossSubstanceId)
                    XCTAssertEqual(pharmaCard.drug.name, brandedDrugTitle)
                    XCTAssertEqual(pharmaCard.drug.eid.value, brandedDrugId)
                    XCTAssertEqual(DataSource.online, datasource)
                    XCTAssertEqual(document, .ifap)
                    XCTAssertNil(group)
                    trackerExp.fulfill()
                default:
                    break
                }
            default:
                XCTFail()
            }
        }

        presenter.loadPharmaCard(for: .fixture(), drugIdentifier: .fixture())
        wait(for: [pharmaCardExp, trackerExp], timeout: 0.1)
    }

    func testThatOnViewDidSetHealthCareProfessionDisclaimerIsShownOnTheViewIfHealthCareProfessionDisclaimerIsNotConfirmed() {
        userDataRepository.hasConfirmedHealthCareProfession = false
        XCTAssertEqual(view.showDisclaimerDialogCallCount, 0)
        presenter.view = view
        XCTAssertEqual(view.showDisclaimerDialogCallCount, 1)
    }

    func testThatOnViewDidSetCloseButtonIsAdded() {
        XCTAssertEqual(view.addCloseButtonCallCount, 0)
        presenter.view = view
        XCTAssertEqual(view.addCloseButtonCallCount, 1)
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
        ifapView.setDataHandler = { result in
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
        ifapView.setDataHandler = { result in
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

        self.presenter.didSelect(drug: newDrug.eid)
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
        ifapView.setDataHandler = { result in
            XCTAssertEqual(pharmaCard.substance.name, result.title)
            if result.sections.count == 1 {
                setEmptyDrugDataExp.fulfill()
            }
        }

        let exp = expectation(description: "Present message is called")
        view.presentSubviewMessageHandler = { _, _ in
            exp.fulfill()
        }

        presenter.didSelect(drug: newDrug.eid)
        wait(for: [setEmptyDrugDataExp, drugExp, exp], timeout: 0.2)
    }
}
