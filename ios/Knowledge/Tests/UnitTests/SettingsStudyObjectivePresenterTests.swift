//
//  SettingsStudyObjectivePresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 26.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import Networking
import XCTest

class SettingsStudyObjectivePresenterTest: XCTestCase {

    var presenter: SettingsStudyObjectivePresenter!

    var view: StudyObjectiveViewTypeMock!
    var repository: StudyObjectiveRepositoryTypeMock!

    override func setUp() {
        view = StudyObjectiveViewTypeMock()
        repository = StudyObjectiveRepositoryTypeMock()
        presenter = SettingsStudyObjectivePresenter(repository: repository)
        presenter.view = view
    }

    func testThatPresenterSetsAllStudyObjectivesOnViewWhenViewIsSet() {
        let studyObjective = StudyObjective.fixture()

        repository.getStudyObjectivesHandler = { completion in
            completion(.success([studyObjective]))
        }

        repository.getStudyObjectiveHandler = { completion in
            completion(.success(studyObjective))
        }

        let expectation = self.expectation(description: "Study objective is set to the view.")
        view.setStudyObjectivesHandler = { studyObjectivesArray in
            XCTAssertEqual(studyObjectivesArray, [studyObjective])
            expectation.fulfill()
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatASubviewErrorIsPresentedWhenTheDataCanNotBePassedToTheView() {

        repository.getStudyObjectivesHandler = { completion in
            completion(.failure(.noInternetConnection))
        }

        let expectation = self.expectation(description: "Present subview error presenter completion is called.")
        view.presentStudyObjectiveSubviewErrorHandler = { _ in
            expectation.fulfill()
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatPresenterSetsCurrentStudyObjectiveOnViewWhenViewIsSet() {
        let studyObjective = StudyObjective.fixture()

        repository.getStudyObjectivesHandler = { completion in
            completion(.success([studyObjective]))
        }

        repository.getStudyObjectiveHandler = { completion in
            completion(.success(studyObjective))
        }

        let expectation = self.expectation(description: "Study objective is set to the view.")
        view.setCurrentStudyObjectiveHandler = { selectedStudyObjectiveId in
            XCTAssertEqual(selectedStudyObjectiveId, studyObjective.eid)
            expectation.fulfill()
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatBottomButtonIsNotActivatedIfTheUserSelectedTheAlreadySelectedStudyObjectiveAgain() {
        let studyObjective = StudyObjective.fixture()

        repository.getStudyObjectivesHandler = { completion in
            completion(.success([studyObjective]))
        }

        repository.getStudyObjectiveHandler = { completion in
            completion(.success(studyObjective))
        }

        presenter.view = view

        XCTAssertEqual(view.setBottomButtonIsEnabledCallCount, 0)
        presenter.selectedStudyObjectiveDidChange(studyObjective: studyObjective)
        XCTAssertEqual(view.setBottomButtonIsEnabledCallCount, 0)
    }

    func testThatBottomButtonIsActivatedIfTheUserSelectedANewStudyObjective() {
        let oldStudyObjective = StudyObjective(eid: "fixture_eid_old", name: "fixture_name_old")
        let newStudyObjective = StudyObjective(eid: "fixture_eid_new", name: "fixture_name_new")

        repository.getStudyObjectivesHandler = { completion in
            completion(.success([oldStudyObjective]))
        }

        repository.getStudyObjectiveHandler = { completion in
            completion(.success(oldStudyObjective))
        }

        presenter.view = view

        XCTAssertEqual(view.setBottomButtonIsEnabledCallCount, 0)
        presenter.selectedStudyObjectiveDidChange(studyObjective: newStudyObjective)
        XCTAssertEqual(view.setBottomButtonIsEnabledCallCount, 1)
    }

    func testThatWhenStudyObjectiveCouldnotBeSetAnAlertErrorIsShown() {
        repository.setStudyObjectiveHandler = { _, completion in
            completion(.failure(.noInternetConnection))
        }

        let expectation = self.expectation(description: "presentStudyObjectiveError completion handler is called")
        view.presentStudyObjectiveAlertErrorHandler = { _ in
            expectation.fulfill()
        }

        presenter.selectedStudyObjectiveDidChange(studyObjective: .fixture())
        presenter.bottomButtonTapped()
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatRepositoryIsCalledWithTheCorrectStudyObjectiveWhenThePresenterSetIt() {
        let studyObjectiveToSet: StudyObjective = .fixture()

        let exp = self.expectation(description: "setStudyObjectiveHandler completion handler is called")
        repository.setStudyObjectiveHandler = { studyObjective, _ in
            XCTAssertEqual(studyObjective, studyObjectiveToSet)
            exp.fulfill()
        }

        presenter.selectedStudyObjectiveDidChange(studyObjective: studyObjectiveToSet)
        presenter.bottomButtonTapped()
        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenUserSubmitsStudyObjectiveThenPresenterCallsTheActivityIndicator() {
        let expectation = self.expectation(description: "setIsLoading is called")

        view.setIsSyncingHandler = { isSyncing in
            XCTAssertEqual(isSyncing, true)
            expectation.fulfill()
        }

        presenter.selectedStudyObjectiveDidChange(studyObjective: .fixture())

        presenter.bottomButtonTapped()

        wait(for: [expectation], timeout: 0.1)
    }
}
