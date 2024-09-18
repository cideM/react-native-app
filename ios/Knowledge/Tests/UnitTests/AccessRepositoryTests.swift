//
//  AccessRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 27.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

import Foundation

class AccessRepositoryTests: XCTestCase {
    private var accessRepository: AccessRepositoryType!
    private var learningCardClient: LearningCardLibraryClientMock!
    private var storage: Storage!

    override func setUp() {
        storage = MemoryStorage()
        learningCardClient = LearningCardLibraryClientMock()
        accessRepository = AccessRepository(learningCardClient: learningCardClient, storage: storage)
    }

    func testThatSettingTheTargetAccessesStoresThemInTheStorage() {
        let accesses: [TargetAccess] = .fixture()

        accessRepository.set(accesses: accesses)

        let storedAccesses: [TargetAccess]? = storage.get(for: .accesses)
        XCTAssertEqual(accesses, storedAccesses)
    }

    func testThatRemoveAllDataFromLocalStorageAlsoRemovesAllAccesses() {
        let accesses: [TargetAccess] = .fixture()
        accessRepository.set(accesses: accesses)

        accessRepository.removeAllDataFromLocalStorage()

        let storedAccesses: [TargetAccess]? = storage.get(for: .accesses)
        XCTAssertNil(storedAccesses)
    }

    func testThatGetAccessForATargetWithUnexpiredAccessGrantsAccess() {
        let exp = expectation(description: "getAccess completed")
        let target: AccessTarget = .fixture()
        let accesses: [TargetAccess] = [
            .fixture(target: target, access: .granted(Date().addingTimeInterval(100 * 60 * 60)))
        ]

        accessRepository.set(accesses: accesses)

        accessRepository.getAccess(for: target) { result in
            switch result {
            case .success: break
            case .failure:
                XCTFail("Should not complete with failure for a target that has an unexpired access")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }

    func testThatGetAccessForATargetWithExpiredAccessDoesntGrantAccess() {
        let exp = expectation(description: "getAccess completed")
        let target: AccessTarget = .fixture()
        let accesses: [TargetAccess] = [
            .fixture(target: target, access: .granted(Date().addingTimeInterval(-1)))
        ]
        learningCardClient.getTargetAccessesHandler = { completion in
            completion(.failure(.failed(code: .fixture())))
        }

        accessRepository.set(accesses: accesses)

        accessRepository.getAccess(for: target) { result in
            switch result {
            case .success:
                XCTFail("Should not complete with success for a target that has an expired access")
            case .failure:
                break
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }

    func testThatGetAccessForATargetWithDeniedAccessDoesntGrantAccess() {
        let exp = expectation(description: "getAccess completed")
        let target: AccessTarget = .fixture()
        let accesses: [TargetAccess] = [
            .fixture(target: target, access: .denied(.offlineAccessExpired))
        ]
        learningCardClient.getTargetAccessesHandler = { completion in
            completion(.failure(.failed(code: .fixture())))
        }

        accessRepository.set(accesses: accesses)

        accessRepository.getAccess(for: target) { result in
            switch result {
            case .success:
                XCTFail("Should not complete with success for a target that has an expired access")
            case .failure:
                break
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }

    func testThatGetAccessForATargetTriesToUpdateTheLocalStorageIfTheStoredAccessIsDenied() {
        let exp = expectation(description: "getAccess completed")
        let target: AccessTarget = .fixture()
        let accesses: [TargetAccess] = [
            .fixture(target: .fixture(), access: .denied(.offlineAccessExpired))
        ]
        learningCardClient.getTargetAccessesHandler = { completion in
            completion(.failure(.failed(code: .fixture())))
        }

        accessRepository.set(accesses: accesses)

        accessRepository.getAccess(for: target) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(learningCardClient.getTargetAccessesCallCount, 1)
    }

    func testThatGetAccessForATargetTriesToUpdateTheLocalStorageIfTheStoredAccessIsExpired() {
        let exp = expectation(description: "getAccess completed")
        let target: AccessTarget = .fixture()
        let accesses: [TargetAccess] = [
            .fixture(target: .fixture(), access: .granted(Date().addingTimeInterval(-1)))
        ]
        learningCardClient.getTargetAccessesHandler = { completion in
            completion(.failure(.failed(code: .fixture())))
        }

        accessRepository.set(accesses: accesses)

        accessRepository.getAccess(for: target) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(learningCardClient.getTargetAccessesCallCount, 1)
    }

    func testThatGetAccessForATargetTriesToUpdateTheLocalStorageIfTheStoredAccessIsNil() {
        let exp = expectation(description: "getAccess completed")
        learningCardClient.getTargetAccessesHandler = { completion in
            completion(.failure(.failed(code: .fixture())))
        }

        accessRepository.set(accesses: [])

        accessRepository.getAccess(for: AccessTarget.fixture()) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(learningCardClient.getTargetAccessesCallCount, 1)
    }

    func testThatGetAccessForLearningCardThatIsAlwaysFreeGrantsAccess() {
        let exp = expectation(description: "getAccess completed")
        let learningCardMetadata: LearningCardMetaItem = .fixture(alwaysFree: true)

        accessRepository.getAccess(for: learningCardMetadata) { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail("Should not complete with success for a target that has an expired access")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
    }
}
