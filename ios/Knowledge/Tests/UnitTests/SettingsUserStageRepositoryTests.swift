//
//  SettingsUserStageRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 26.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
@testable import Knowledge_DE
import XCTest

class SettingsUserStageRepositoryTests: XCTestCase {

    var repository: UserStageRepositoryType!
    var userDataClient: UserDataClientMock!

    override func setUp() {
        userDataClient = UserDataClientMock()
        repository = SettingsUserStageRepository(userDataRepository: UserDataRepositoryTypeMock(), userDataClient: userDataClient)
    }

    func testThatWhenUserStageIsSetThenShouldReturnSuccessInCaseServerUploadWasSuccess() {
        userDataClient.setUserStageHandler = { _, completion in
            completion(.success(()))
        }

        let expectation = self.expectation(description: "setUserStage is called")

        repository.setUserStage(.clinic) { result in
            if case .success = result {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenUserStageIsSetThenShouldReturnFailureInCaseServerUploadWasNotSuccess() {
        userDataClient.setUserStageHandler = { _, completion in
            completion(.failure(.other("")))
        }

        let expectation = self.expectation(description: "setUserStage is called")

        repository.setUserStage(.clinic) { result in
            if case .failure = result {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 0.1)
    }
}
