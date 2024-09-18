//
//  RegistrationUserStagePresenterTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 26.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
@testable import Knowledge_DE
import XCTest
import Domain
import DesignSystem

class RegistrationUserStagePresenterTests: XCTestCase {

    var presenter: UserStagePresenterType!
    var viewMock: UserStageViewTypeMock!
    var coordinator: AuthenticationCoordinatorTypeMock!
    var userStageRepository: UserStageRepositoryTypeMock!
    var registrationRepository: RegistrationRepositoryTypeMock!
    var trackingProvider: TrackingTypeMock!
    var appConfiguration: ConfigurationMock!
    var userStages: [UserStage]!

    override func setUp() {
        DesignSystem.initialize()
        viewMock = UserStageViewTypeMock()
        coordinator = AuthenticationCoordinatorTypeMock()
        userStageRepository = UserStageRepositoryTypeMock()
        registrationRepository = RegistrationRepositoryTypeMock()
        trackingProvider = TrackingTypeMock()
        appConfiguration = ConfigurationMock()
        userStages = [.clinic, .physician]

        presenter = RegistrationUserStagePresenter(coordinator: coordinator,
                                                   userStageRepository: userStageRepository,
                                                   registrationRepository: registrationRepository,
                                                   userStages: userStages,
                                                   trackingProvider: trackingProvider,
                                                   configuration: appConfiguration)
    }

    override class func tearDown() {
        DesignSystem.deinitialize()
    }

    func testThatTheRightUrlIsPassedToCoordinatorWhenAFooterLinkIsTapped() {
        let tappedUrl: URL = .fixture()
        let expectation = self.expectation(description: "Coordinator openURL was called")
        coordinator.goToUrlHandler = { url in
            XCTAssertEqual(tappedUrl, url)
            expectation.fulfill()
        }

        presenter.agreementTapped(url: tappedUrl)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenUserSelectsTheUserStageThenRepositoryIsNotCalledToSaveIt() {
        XCTAssertEqual(userStageRepository.setUserStageCallCount, 0)

        presenter.didSelectUserStage(.preclinic)

        XCTAssertEqual(userStageRepository.setUserStageCallCount, 0)
    }

    func testThatTappingPrimaryButtonOfTheFooterViewThenTheUserStageRepositoryIsCalledToSaveTheSelectedUserStage() {
        let userStage: UserStage = .fixture()
        presenter.didSelectUserStage(userStage)
        let expectation = self.expectation(description: "setUserStage was called")
        userStageRepository.setUserStageHandler = { userStageToSave, _ in
            XCTAssertEqual(userStage, userStageToSave)
            expectation.fulfill()
        }

        presenter.primaryButtonTapped()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingPrimaryButtonOfTheFooterViewThenTheRegistrationRepositoryIsCalledToSaveTheSelectedUserStage() {
        let userStage: UserStage = .fixture()
        presenter.didSelectUserStage(userStage)
        let expectation = self.expectation(description: "setUserStage was called")
        userStageRepository.setUserStageHandler = { _, completion in
            completion(.success(()))
            expectation.fulfill()
        }

        XCTAssertEqual(registrationRepository.userStageSetCallCount, 0)

        presenter.primaryButtonTapped()

        XCTAssertEqual(registrationRepository.userStageSetCallCount, 1)
        XCTAssertEqual(registrationRepository.userStage, userStage)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingPrimaryButtonOfTheFooterViewShowsTheLoadingIndicator() {
        let userStage: UserStage = .fixture()
        presenter.view = viewMock
        presenter.didSelectUserStage(userStage)
        let expectation = self.expectation(description: "setIsLoading was called")
        viewMock.setIsLoadingHandler = { isLoading in
            XCTAssertEqual(isLoading, true)
            expectation.fulfill()
        }

        presenter.primaryButtonTapped()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingPrimaryButtonOfTheFooterViewAsksTheCoordinatorToGoToRegistrationScreenIfTheAppConfigurationHasNoStudyObjectiveScreen() {
        appConfiguration.hasStudyObjective = false
        let userStage: UserStage = .fixture()
        presenter.view = viewMock
        presenter.didSelectUserStage(userStage)
        let expectation = self.expectation(description: "setUserStage was called")
        userStageRepository.setUserStageHandler = { _, completion in
            completion(.success(()))
            expectation.fulfill()
        }
        XCTAssertEqual(coordinator.goToRegistrationCallCount, 0)

        presenter.primaryButtonTapped()

        XCTAssertEqual(coordinator.goToRegistrationCallCount, 1)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingPrimaryButtonOfTheFooterViewAsksTheCoordinatorToGoToStudyObjectiveSelectionScreenIfTheAppConfigurationHasStudyObjectiveScreenAndTheUserSelectedStudent() {
        appConfiguration.hasStudyObjective = true
        let userStage: UserStage = .clinic
        presenter.view = viewMock
        presenter.didSelectUserStage(userStage)
        let expectation = self.expectation(description: "setUserStage was called")
        userStageRepository.setUserStageHandler = { _, completion in
            completion(.success(()))
            expectation.fulfill()
        }
        XCTAssertEqual(coordinator.goToStudyObjectiveSelectionCallCount, 0)

        presenter.primaryButtonTapped()

        XCTAssertEqual(coordinator.goToStudyObjectiveSelectionCallCount, 1)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingPrimaryButtonOfTheFooterViewAsksTheCoordinatorToGoToPurposeSelectionScreenIfTheAppConfigurationHasStudyObjectiveScreenAndTheUserSelectedPhysician() {
        appConfiguration.hasStudyObjective = true
        let userStage: UserStage = .physician
        presenter.view = viewMock
        presenter.didSelectUserStage(userStage)
        let expectation = self.expectation(description: "setUserStage was called")
        userStageRepository.setUserStageHandler = { _, completion in
            completion(.success(()))
            expectation.fulfill()
        }
        XCTAssertEqual(coordinator.goToPurposeSelectionCallCount, 0)

        presenter.primaryButtonTapped()

        XCTAssertEqual(coordinator.goToPurposeSelectionCallCount, 1)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenUserStageCouldNotBeSetAnErrorIsShown() {
        let userStage: UserStage = .fixture()
        presenter.view = viewMock
        userStageRepository.setUserStageHandler = { _, completion in
            completion(.failure(.noInternetConnection))
        }
        let expectation = self.expectation(description: "presentMessage is called")
        viewMock.presentMessageHandler = { _ in
             expectation.fulfill()
        }
        presenter.didSelectUserStage(userStage)

        presenter.primaryButtonTapped()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatUserStagesArePassedToTheViewAfterItIsSetToThePresenter() {

        let expectation = self.expectation(description: "View set items is called")

        viewMock.setViewDataHandler = { data in
            XCTAssertEqual(data.items.count, self.userStages.count)
            XCTAssertEqual(data.items[0].stage, self.userStages[0])

            expectation.fulfill()
        }

        presenter.view = viewMock

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatUserStageIsSetToNilOnRegistrationRepositoryWhenThePresenterIsDeallocated() {
        var presenter: RegistrationUserStagePresenter? = RegistrationUserStagePresenter(coordinator: coordinator, userStageRepository: userStageRepository, registrationRepository: registrationRepository, userStages: userStages, trackingProvider: trackingProvider, configuration: appConfiguration)
        registrationRepository.userStage = .fixture()

        if presenter != nil { presenter = nil }

        XCTAssertNil(registrationRepository.studyObjective)
    }
}
