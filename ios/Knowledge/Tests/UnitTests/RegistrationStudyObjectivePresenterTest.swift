//
//  RegistrationStudyObjectivePresenterTest.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 21.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import Networking
import XCTest

class RegistrationStudyObjectivePresenterTest: XCTestCase {

    var presenter: RegistrationStudyObjectivePresenter!

    var view: StudyObjectiveViewTypeMock!
    var studyObjectiveRepository: StudyObjectiveRepositoryTypeMock!
    var registrationRepository: RegistrationRepositoryTypeMock!
    var coordinator: AuthenticationCoordinatorTypeMock!

    override func setUp() {
        view = StudyObjectiveViewTypeMock()
        studyObjectiveRepository = StudyObjectiveRepositoryTypeMock()
        registrationRepository = RegistrationRepositoryTypeMock()
        coordinator = AuthenticationCoordinatorTypeMock()

        presenter = RegistrationStudyObjectivePresenter(coordinator: coordinator, studyObjectiveRepository: studyObjectiveRepository, registrationRepository: registrationRepository)

        presenter.view = view
    }

    func testThatPresenterSetsAllStudyObjectivesOnViewWhenViewIsSet() {
        let studyObjective = StudyObjective.fixture()

        studyObjectiveRepository.getStudyObjectivesHandler = { completion in
            completion(.success([studyObjective]))
        }

        let expectation = self.expectation(description: "Study objectives is set to the view.")
        view.setStudyObjectivesHandler = { studyObjectivesArray in
            XCTAssertEqual(studyObjectivesArray, [studyObjective])
            expectation.fulfill()
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatPresenterSetsTheActivityIndicatorOnViewWhenViewIsSet() {
        let studyObjective = StudyObjective.fixture()

        studyObjectiveRepository.getStudyObjectivesHandler = { completion in
            completion(.success([studyObjective]))
        }

        let expectation = self.expectation(description: "Study objectives are set to the view.")
        view.setStudyObjectivesHandler = { studyObjectivesArray in
            XCTAssertEqual(studyObjectivesArray, [studyObjective])
            expectation.fulfill()
        }

        XCTAssertEqual(view.setIsSyncingCallCount, 1)

        presenter.view = view

        XCTAssertEqual(view.setIsSyncingCallCount, 3)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatASubviewErrorIsPresentedWhenTheDataCanNotBePassedToTheView() {

        studyObjectiveRepository.getStudyObjectivesHandler = { completion in
            completion(.failure(.noInternetConnection))
        }

        let expectation = self.expectation(description: "Present subview error presenter completion is called.")
        view.presentStudyObjectiveSubviewErrorHandler = { _ in
            expectation.fulfill()
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatPresenterDoesNotSetCurrentStudyObjectiveOnViewWhenViewIsSet() {
        let studyObjective = StudyObjective.fixture()

        studyObjectiveRepository.getStudyObjectivesHandler = { completion in
            completion(.success([studyObjective]))
        }

        studyObjectiveRepository.getStudyObjectiveHandler = { completion in
            completion(.success(studyObjective))
        }

        XCTAssertEqual(view.setCurrentStudyObjectiveCallCount, 0)

        presenter.view = view

        XCTAssertEqual(view.setCurrentStudyObjectiveCallCount, 0)
    }

    func testThatBottomButtonIsActivatedIfTheUserSelectedAnyStudyObjective() {
        let studyObjective = StudyObjective.fixture()

        studyObjectiveRepository.getStudyObjectivesHandler = { completion in
            completion(.success([studyObjective]))
        }

        presenter.view = view

        XCTAssertEqual(view.setBottomButtonIsEnabledCallCount, 0)
        presenter.selectedStudyObjectiveDidChange(studyObjective: studyObjective)
        XCTAssertEqual(view.setBottomButtonIsEnabledCallCount, 1)
    }

    func testThatTheSelectedStudyObjectiveIsSetToRegistrationRepositoryWhenTheUserTapsTheBottomButton() {
        let selectedStudyObjective: StudyObjective = .fixture()
        presenter.selectedStudyObjectiveDidChange(studyObjective: selectedStudyObjective)
        XCTAssertEqual(registrationRepository.studyObjectiveSetCallCount, 0)

        presenter.bottomButtonTapped()

        XCTAssertEqual(registrationRepository.studyObjectiveSetCallCount, 1)
    }

    func testThatTheCoordinatorIsCalledToGoToRegistrationScreenWhenTheUserTapsTheBottomButton() {
        let selectedStudyObjective: StudyObjective = .fixture()
        presenter.selectedStudyObjectiveDidChange(studyObjective: selectedStudyObjective)
        XCTAssertEqual(coordinator.goToRegistrationCallCount, 0)

        presenter.bottomButtonTapped()

        XCTAssertEqual(registrationRepository.studyObjectiveSetCallCount, 1)
    }

    func testThatStudyObjectiveIsSetToNilOnRegistrationRepositoryWhenThePresenterIsDeallocated() {
        var presenter: RegistrationStudyObjectivePresenter? = RegistrationStudyObjectivePresenter(coordinator: coordinator, studyObjectiveRepository: studyObjectiveRepository, registrationRepository: registrationRepository)
        registrationRepository.studyObjective = .fixture()

        if presenter != nil { presenter = nil }

        XCTAssertNil(registrationRepository.studyObjective)
    }
}
