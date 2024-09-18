//
//  PharmaRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 13.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import Networking
@testable import PharmaDatabase
import XCTest

class PharmaRepositoryTests: XCTestCase {

    var pharmaRepository: PharmaRepositoryType!
    var pharmaRepositoryMock: PharmaRepositoryTypeMock!
    var pharmaDatabase: PharmaDatabaseTypeMock!
    var pharmaService: PharmaDatabaseApplicationServiceTypeMock!
    var trackingProvider: TrackingTypeMock!
    var pharmaClient: PharmaClientMock!
    var userDefaultsStorage: Storage!
    var drugList: [DrugReference] = []
    var monitor: MonitoringMock!

    override func setUp() {
        pharmaClient = PharmaClientMock()
        userDefaultsStorage = MemoryStorage()
        pharmaDatabase = PharmaDatabaseTypeMock()
        trackingProvider = TrackingTypeMock()
        pharmaService = PharmaDatabaseApplicationServiceTypeMock(pharmaDatabase: pharmaDatabase, state: .idle(error: nil, availableUpdate: nil, type: .automatic))

        monitor = MonitoringMock()

        pharmaRepository = PharmaRepository(pharmaClient: pharmaClient, userDefaultsStorage: userDefaultsStorage, pharmaService: pharmaService, remoteConfigRepository: RemoteConfigRepositoryTypeMock(), monitor: monitor)
    }

    func testThatWhenFetchingPharmaCardDataSucceedsThenRepositoryReturnsSuccess() {
        let expectedPharmaCardResult: PharmaCard = .fixture()

        pharmaClient.getPharmaCardHandler = { _, _, _, _, _, completion in
            completion(.success(expectedPharmaCardResult))
        }

        let expectation = self.expectation(description: "PharmaRepository pharmaCard completion is called")

        pharmaRepository.pharmaCard(for: .fixture(), drugIdentifier: .fixture(), sorting: .fixture(), cachePolicy: .reloadIgnoringLocalCacheData) { result in
            switch result {
            case .success((let pharmaCard, _)):
                XCTAssertEqual(pharmaCard.substance.id, expectedPharmaCardResult.substance.id)
                XCTAssertEqual(pharmaCard.drug.eid, expectedPharmaCardResult.drug.eid)
            case .failure: XCTFail("PharmaRepository failed to fetch pharmaCard data.")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenFetchingPharmaCardDataFromServerFailsButSucceedsFromDatabaseThenRepositoryReturnsSuccess() {
        pharmaClient.getPharmaCardHandler = { _, _, _, _, _, completion in
            completion(.failure(.noInternetConnection))
        }

        let expectation = self.expectation(description: "PharmaRepository pharmaCard completion is called")

        let expectedAgent = Substance.fixture()
        let expectedDrug = Drug.fixture()
        pharmaDatabase.substanceHandler = { _ in
            expectedAgent
        }

        pharmaDatabase.drugHandler = { _, _ in
            expectedDrug
        }

        pharmaRepository.pharmaCard(for: .fixture(), drugIdentifier: .fixture(), sorting: .fixture(), cachePolicy: .reloadIgnoringLocalCacheData) { result in
            switch result {
            case .success((let pharmaCard, let source)):
                XCTAssertEqual(pharmaCard.substance.id, expectedAgent.id)
                XCTAssertEqual(pharmaCard.drug.eid, expectedDrug.eid)
                XCTAssertEqual(source, .offline)
            case .failure:
                XCTFail("PharmaRepository failed to fetch pharmaCard data.")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenFetchingPharmaCardDataFailsThenRepositoryReturnsFailure() {
        pharmaClient.getPharmaCardHandler = { _, _, _, _, _, completion in
            completion(.failure(.noInternetConnection))
        }

        let expectation = self.expectation(description: "PharmaRepository pharmaCard completion is called")

        pharmaService.pharmaDatabase = nil

        pharmaRepository.pharmaCard(for: .fixture(), drugIdentifier: .fixture(), sorting: .fixture(), cachePolicy: .reloadIgnoringLocalCacheData) { result in
            switch result {
            case .success: XCTFail("PharmaRepository didn't fail after the pharmaClient's failure.")
            case .failure(let error):
                XCTAssertEqual(error.body, NetworkError<EmptyAPIError>.noInternetConnection.body)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenFetchingPharmaCardDataFromServerAndFromDBFailsThenRepositoryReturnsTheNetworkErrorAndTracksTheDBError() {
        pharmaClient.getPharmaCardHandler = { _, _, _, _, _, completion in
            completion(.failure(.noInternetConnection))
        }

        pharmaDatabase.substanceHandler = { _ in
            throw PharmaDatabase.FetchError.rowMissing(table: "substance")
        }
        pharmaDatabase.drugHandler = { _, _ in
            throw PharmaDatabase.FetchError.rowMissing(table: "drug")
        }

        let errorTrackingExpectation = expectation(description: "Error was tracked")
        monitor.logHandler = { object, _, _, _, _, _ in
            guard let _ = object() as? PharmaDatabase.FetchError else {
                return XCTFail("Error should be of type PharmaDatabase.FetchError but is: \(String(describing: object()))")
            }
            errorTrackingExpectation.fulfill()
        }

        let pharmaCardExpectation = expectation(description: "PharmaRepository pharmaCard completion is called")
        pharmaRepository.pharmaCard(for: .fixture(), drugIdentifier: .fixture(), sorting: .fixture(), cachePolicy: .reloadIgnoringLocalAndRemoteCacheData) { result in
            switch result {
            case .success:
                XCTFail("Request should not succeed")
            case .failure(let error):
                XCTAssertEqual(error.body, NetworkError<EmptyAPIError>.noInternetConnection.body)
                pharmaCardExpectation.fulfill()
            }
        }

        wait(for: [pharmaCardExpectation, errorTrackingExpectation], timeout: 0.1)
    }

    func testThatWhenFetchingDrugDataSucceedsThenTheRepositoryReturnsSuccess() {
        let expectedDrugResult: Drug = .fixture()

        pharmaClient.getDrugHandler = { _, _, _, _, completion in
            completion(.success(expectedDrugResult))
        }

        let expectation = self.expectation(description: "PharmaRepository drug completion is called")

        pharmaRepository.drug(for: expectedDrugResult.eid, sorting: .fixture()) { result in
            switch result {
            case .success((let drug, _)):
                XCTAssertEqual(drug.eid, expectedDrugResult.eid)
            case .failure:
                XCTFail("PharmaRepository failed to fetch agent data.")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenFetchingDrugDataFromServerFailsButSucceedsFromDatabaseThenTheRepositoryReturnsSuccess() {
        let expectedDrugResult: Drug = .fixture()
        pharmaDatabase.drugHandler = { _, _ in
            expectedDrugResult
        }

        pharmaClient.getDrugHandler = { _, _, _, _, completion in
            completion(.failure(.noInternetConnection))
        }

        let expectation = self.expectation(description: "PharmaRepository drug completion is called")

        pharmaRepository.drug(for: expectedDrugResult.eid, sorting: .fixture()) { result in
            switch result {
            case .success((let drug, _)):
                XCTAssertEqual(drug.eid, expectedDrugResult.eid)
            case .failure:
                XCTFail("PharmaRepository failed to fetch agent data.")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenFetchingDrugDataFromServerAndFromDBFailsThenTheRepositoryReturnsTheNetworkErrorAndTracksTheDBError() {
        let expectedDrugResult: Drug = .fixture()
        pharmaDatabase.drugHandler = { _, _ in
            throw PharmaDatabase.FetchError.rowMissing(table: "drug")
        }

        pharmaClient.getDrugHandler = { _, _, _, _, completion in
            completion(.failure(.noInternetConnection))
        }

        let errorTrackingExpectation = expectation(description: "Error should be tracked")
        monitor.logHandler = { object, _, _, _, _, _ in
            guard let _ = object() as? PharmaDatabase.FetchError else {
                return XCTFail("Error should be of type PharmaDatabase.FetchError but is: \(String(describing: object()))")
            }
            errorTrackingExpectation.fulfill()
        }

        let drugExpectation = self.expectation(description: "PharmaRepository drug completion is called")
        pharmaRepository.drug(for: expectedDrugResult.eid, sorting: .fixture()) { result in
            switch result {
            case .success:
                XCTFail("Request should not succeed")
            case .failure(let error):
                XCTAssertEqual(error.body, NetworkError<EmptyAPIError>.noInternetConnection.body)
                drugExpectation.fulfill()
            }
        }

        wait(for: [drugExpectation, errorTrackingExpectation], timeout: 0.1)
    }
}
