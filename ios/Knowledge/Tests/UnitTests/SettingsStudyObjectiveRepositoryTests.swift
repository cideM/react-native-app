//
//  SettingsStudyObjectiveRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Azadeh Richter on 20.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import Networking
import XCTest

class SettingsStudyObjectiveRepositoryTests: XCTestCase {

    // MARK: - Subject under test
    var repository: StudyObjectiveRepositoryType!

    // MARK: - Subject dependencies
    var userDataRepository: UserDataRepositoryType!
    var userDataClient: UserDataClientMock!
    var authenticationClient: AuthenticationClientMock!

    // MARK: - Test lifecyle
    override func setUp() {
        super.setUp()
        userDataClient = UserDataClientMock()
        userDataRepository = UserDataRepositoryTypeMock()
        authenticationClient = AuthenticationClientMock()
        repository = SettingsStudyObjectiveRepository(userDataRepository: userDataRepository, userDataClient: userDataClient)
    }

    // MARK: - Tests

    func testGetAvailableStudyObjectivesReturnsStudyObjectivesWhenClientResponseIsSuccess() {
        // Given
        let expectedStudyObjectives = [StudyObjective.fixture(), StudyObjective.fixture()]
        userDataClient.getAvailableStudyObjectivesHandler = { completion in
            completion(.success(expectedStudyObjectives))
        }
        let resultExpectation = expectation(description: "Wait for the client to respond!")

        // When & then
        repository.getStudyObjectives { result in
            resultExpectation.fulfill()

            switch result {
            case .success(let studyObjectives):
                XCTAssertEqual(studyObjectives, expectedStudyObjectives)
            case .failure:
                XCTFail("GetAvailableStudyObjectives should not fail!")
            }
        }

        XCTAssertEqual(userDataClient.getAvailableStudyObjectivesCallCount, 1)
        wait(for: [resultExpectation], timeout: 0.1)
    }

    func testGetAvailableStudyObjectivesReturnsErrorWhenClientResponseIsFailure() {
        // Given
        userDataClient.getAvailableStudyObjectivesHandler = { completion in
            completion(.failure(.requestTimedOut))
        }
        let resultExpectation = expectation(description: "Wait for the client to respond!")

        // When & then
        repository.getStudyObjectives { result in
            resultExpectation.fulfill()
            switch result {
            case .success:
                XCTFail("GetAvailableStudyObjectives should not succeed!")
            case .failure(let error):
                if case NetworkError.requestTimedOut = error {
                   break
                } else {
                    XCTFail("The returned error should be the same as the client's error!")
                }
            }
        }

        XCTAssertEqual(userDataClient.getAvailableStudyObjectivesCallCount, 1)
        wait(for: [resultExpectation], timeout: 0.1)
    }

    func testSetStudyObjectiveReturnsSuccessAndUpdatesUserDataRepositoryWhenClientResponseIsSuccess() {
        // Given
        let studyObjective = StudyObjective.fixture()
        userDataClient.setStudyObjectiveHandler = { _, completion in
            completion(.success(()))
        }
        let resultExpectation = expectation(description: "Wait for the client to respond")

        // When & then
        repository.setStudyObjective(studyObjective) { [weak self] result in
            resultExpectation.fulfill()
            switch result {
            case .success:
                XCTAssertEqual(self?.userDataRepository.studyObjective, studyObjective)
            case .failure:
                XCTFail("SetStudyObjective should not fail!")
            }
        }

        XCTAssertEqual(userDataClient.setStudyObjectiveCallCount, 1)
        wait(for: [resultExpectation], timeout: 0.1)
    }

    func testSetStudyObjectiveReturnsErrorWhenClientResponseIsFailure() {
        // Given
        let studyObjective = StudyObjective.fixture()
        userDataClient.setStudyObjectiveHandler = { _, completion in
            completion(.failure(.requestTimedOut))
        }
        let resultExpectation = expectation(description: "Wait for the client to respond!")

        // When & then
        repository.setStudyObjective(studyObjective) { result in
            resultExpectation.fulfill()
            switch result {
            case .success:
                XCTFail("SetStudyObjective should not succeed!")
            case .failure(let error):
                if case NetworkError.requestTimedOut = error {
                   break
                } else {
                    XCTFail("The returned error should be the same as the client's error!")
                }
            }
        }

        XCTAssertEqual(userDataClient.setStudyObjectiveCallCount, 1)
        wait(for: [resultExpectation], timeout: 0.1)
    }

    func testGetStudyObjectiveReturnsValueStoredInUserDataRepository() {
        // Given
        let expectedStudyObjective = StudyObjective.fixture()
        userDataRepository.studyObjective = expectedStudyObjective
        let resultExpectation = expectation(description: "Wait for the completion block")

        // When & then
        repository.getStudyObjective { result in
            resultExpectation.fulfill()
            switch result {
            case let .success(studyObjective):
                XCTAssertEqual(studyObjective, expectedStudyObjective)
            case .failure:
                XCTFail("GetStudyObjective should not fail!")
            }
        }

        wait(for: [resultExpectation], timeout: 0.1)
    }

    func testGetStudyObjectiveDoesNotInitiateAnyNetworkCalls() {
        // Given
        let resultExpectation = expectation(description: "Wait for the completion block")

        // When & then
        repository.getStudyObjective {_ in
            resultExpectation.fulfill()
        }

        XCTAssertEqual(userDataClient.getAvailableStudyObjectivesCallCount, 0)
        XCTAssertEqual(authenticationClient.getRegistrationStudyObjectivesCallCount, 0)
        wait(for: [resultExpectation], timeout: 0.1)
    }
}
