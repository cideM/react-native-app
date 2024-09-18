//
//  UsagePurposePresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 27.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class UsagePurposePresenterTests: XCTestCase {

    var presenter: UsagePurposePresenter!

    var view: UsagePurposeViewTypeMock!
    var coordinator: AuthenticationCoordinatorTypeMock!
    var registrationRepository: RegistrationRepositoryTypeMock!

    override func setUp() {
        view = UsagePurposeViewTypeMock()
        coordinator = AuthenticationCoordinatorTypeMock()
        registrationRepository = RegistrationRepositoryTypeMock()

        presenter = UsagePurposePresenter(coordinator: coordinator, registrationRepository: registrationRepository)
        presenter.view = view
    }

    func testThatTheUsagePurposesAreSetOnTheViewWhenTheViewIsSetToThePresenter() {
        XCTAssertEqual(view.setUsagePurposesCallCount, 1)

        presenter.view = view

        XCTAssertEqual(view.setUsagePurposesCallCount, 2)
    }

    func testThatStudySelectingExamPreparationAsksTheCoordinatorToGoToStudyObjectiveSelectionScreen() {
        registrationRepository.userStage = .physician
        XCTAssertEqual(coordinator.goToStudyObjectiveSelectionCallCount, 0)

        presenter.didSelectUsagePurpose(.examPreparation)

        XCTAssertEqual(coordinator.goToStudyObjectiveSelectionCallCount, 1)
    }

    func testThatStudySelectingClinicalPracticeAsksTheCoordinatorToGoToRegistrationScreen() {
        registrationRepository.userStage = .physician
        XCTAssertEqual(coordinator.goToRegistrationCallCount, 0)

        presenter.didSelectUsagePurpose(.clinicalPractice)

        XCTAssertEqual(coordinator.goToRegistrationCallCount, 1)
    }
}
