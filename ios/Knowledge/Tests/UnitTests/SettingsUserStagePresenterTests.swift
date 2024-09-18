//
//  SettingsUserStagePresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 26.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest
import Localization

import Domain

class SettingsUserStagePresenterTests: XCTestCase {

    var presenter: SettingsUserStagePresenter!
    var view: UserStageViewTypeMock!
    var coordinator: UserStageCoordinatorTypeMock!
    var userStageRepository: UserStageRepositoryTypeMock!
    var userStages: [UserStage]!

    override func setUp() {
        view = UserStageViewTypeMock()
        coordinator = UserStageCoordinatorTypeMock()
        userStageRepository = UserStageRepositoryTypeMock()
        userStages = [.clinic, .physician, .preclinic]

        presenter = SettingsUserStagePresenter(repository: userStageRepository, coordinator: coordinator, userStages: userStages, analyticsTracking: TrackingTypeMock(), referer: .settings)
    }

    func testThatDidSetViewSetsUserStageItemsOnTheView() {
        let setItemsExpectation = self.expectation(description: "setItems is called")

        view.setViewDataHandler = { data in
            let expectedItems = self.userStages.map { UserStageViewData.Item($0) }
            XCTAssertEqual(data.items, expectedItems)
            setItemsExpectation.fulfill()
        }

        presenter.view = view

        wait(for: [setItemsExpectation], timeout: 0.1)
    }

    func testThatDidSetViewSetsTheSelectedUserStageOnTheView() {
        let userStage: UserStage = .fixture()
        userStageRepository.getUserStageHandler = { completion in
            completion(.success(userStage))
        }

        let selectUserStageExpectation = self.expectation(description: "selectUserStage is called")

        view.selectUserStageHandler = { item in
            XCTAssertEqual(item, userStage)
            selectUserStageExpectation.fulfill()
        }

        presenter.view = view

        wait(for: [selectUserStageExpectation], timeout: 0.1)
    }

    func testThatDidSelectUserStageDoesntUpdateTheRepository() {
        XCTAssertEqual(userStageRepository.setUserStageCallCount, 0)

        presenter.didSelectUserStage(.preclinic)

        XCTAssertEqual(userStageRepository.setUserStageCallCount, 0)
    }

    func testThatDidSelectUserStageShowsTheUserStageAgreement() {
        let userStage = UserStage.fixture()
        presenter.view = view

        let setDisclaimerExpectation = self.expectation(description: "setDisclaimer is called")
        view.setDisclaimerHandler = { state, _ in
            if case let .shown(disclaimer, buttonTitle) = state {
                XCTAssertEqual(disclaimer, userStage.agreementMessage)
                XCTAssertEqual(buttonTitle, L10n.Generic.save)
                setDisclaimerExpectation.fulfill()
            }
        }

        presenter.didSelectUserStage(userStage)
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testThatDidSelectUserStageDoesntShowTheUserStageAgreementIfTheUserStageWasntChanged() {
        let userStage = UserStage.fixture()
        presenter.view = view
        presenter.didSelectUserStage(userStage)

        view.setDisclaimerHandler = { _, _ in
            XCTFail()
        }

        presenter.didSelectUserStage(userStage)
    }

    func testThatAgreementTappedCallsOpenURLWithTheCorrectURLOnTheCoordinator() {
        let tappedUrl: URL = .fixture()
        let openURLExpectation = self.expectation(description: "openURL was called")
        coordinator.openURLHandler = { url in
            XCTAssertEqual(tappedUrl, url)
            openURLExpectation.fulfill()
        }

        presenter.agreementTapped(url: tappedUrl)

        wait(for: [openURLExpectation], timeout: 0.1)
    }

    func testThatPrimaryButtonTappedUpdatesTheUserStageInTheRepository() {
        let userStage: UserStage = .fixture()
        presenter.didSelectUserStage(userStage)
        let setUserStageExpectation = self.expectation(description: "setUserStage was called")
        userStageRepository.setUserStageHandler = { userStageToSave, _ in
            XCTAssertEqual(userStage, userStageToSave)
            setUserStageExpectation.fulfill()
        }

        presenter.primaryButtonTapped()

        wait(for: [setUserStageExpectation], timeout: 0.1)
    }

    func testThatPrimaryButtonTappedDisplaysSaveNotification() {

        let expectation = expectation(description: "Disclaimer was dismissed")
        expectation.expectedFulfillmentCount = 2

        userStageRepository.setUserStageHandler = { _, completion in
            completion(.success(()))
        }

        view.setDisclaimerHandler = { _, completion in
            expectation.fulfill()
            completion()
        }

        presenter.view = view
        presenter.didSelectUserStage(.fixture())
        presenter.primaryButtonTapped()

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(view.showSaveNotificationCallCount, 1)
    }

    func testThatPrimaryButtonTappedShowsTheLoadingIndicator() {
        let userStage: UserStage = .fixture()
        presenter.view = view
        presenter.didSelectUserStage(userStage)
        let setIsLoadingExpectation = self.expectation(description: "setIsLoading was called")
        view.setIsLoadingHandler = { isLoading in
            XCTAssertEqual(isLoading, true)
            setIsLoadingExpectation.fulfill()
        }

        presenter.primaryButtonTapped()

        wait(for: [setIsLoadingExpectation], timeout: 0.1)
    }

    func testThatPrimaryButtonTappedShowsAnErrormessageIfTheUserstageCouldNotBeSaved() {
        presenter.view = view
        userStageRepository.setUserStageHandler = { _, completion in
            completion(.failure(.noInternetConnection))
        }
        let presentMessageExpectation = self.expectation(description: "presentMessage is called")
        view.presentMessageHandler = { _ in
            presentMessageExpectation.fulfill()
        }
        presenter.didSelectUserStage(.fixture())

        presenter.primaryButtonTapped()

        wait(for: [presentMessageExpectation], timeout: 0.1)
    }

    func testThatPrimaryButtonTappedHidesTheDisclaimerIfTheUserstageWasSaved() {
        presenter.view = view
        presenter.didSelectUserStage(.fixture())
        userStageRepository.setUserStageHandler = { _, completion in
            completion(.success(()))
        }
        let setDisclaimerExpectation = self.expectation(description: "setDisclaimerIsVisible is called")
        view.setDisclaimerHandler = { state, _ in
            XCTAssertEqual(state, .hidden)
            setDisclaimerExpectation.fulfill()
        }

        presenter.primaryButtonTapped()

        wait(for: [setDisclaimerExpectation], timeout: 0.1)
    }
}
