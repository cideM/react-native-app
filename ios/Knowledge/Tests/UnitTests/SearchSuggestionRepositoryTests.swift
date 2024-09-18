//
//  SearchSuggestionRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 02.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

import Foundation
import Domain

class SearchSuggestionRepositoryTests: XCTestCase {

    var searchClient: SearchClientMock!
    var repository: SearchSuggestionRepositoryType!
    var library: LibraryTypeMock!
    var pharmaDatabaseMock: PharmaDatabaseTypeMock!
    var pharmaServiceMock: PharmaDatabaseApplicationServiceTypeMock!
    var remoteConfigRepositoryMock: RemoteConfigRepositoryTypeMock!

    override func setUp() {
        library = LibraryTypeMock(metadata: LibraryMetadata.fixture(), autolinks: [Autolink.fixture(phrase: "spec_1")])
        searchClient = SearchClientMock()
        pharmaDatabaseMock = PharmaDatabaseTypeMock()
        pharmaServiceMock = PharmaDatabaseApplicationServiceTypeMock()
        pharmaServiceMock.pharmaDatabase = pharmaDatabaseMock
        remoteConfigRepositoryMock = RemoteConfigRepositoryTypeMock()

        let libraryRepository = LibraryRepositoryTypeMock()
        libraryRepository.library = library

        repository = SearchSuggestionRepository(searchClient: searchClient, libraryRepository: libraryRepository, pharmaService: pharmaServiceMock, remoteConfigRepository: remoteConfigRepositoryMock)
    }

    func testThatOnlineSuggestionsAreReturnedWhenTheClientSucceeds() {
        let expectedValue = "spec_1"
        let expectedSuggestions = [SearchSuggestionItem.autocomplete(text: "spec_1", value: expectedValue, metadata: .fixture())]

        searchClient.getSuggestionsHandler = { _, _, _, completion in
            completion(.success(expectedSuggestions))
        }

        let expectation = self.expectation(description: "repository suggestions is completed")
        repository.suggestions(for: "spec") { suggestionsResult in

            if case .autocomplete(_, let value, _) = suggestionsResult.suggestions.first {
                XCTAssertEqual(value, expectedValue)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(searchClient.getSuggestionsCallCount, 1)
    }

    func testThatAutolinkSuggestionsAreReturnedWhenTheClientFails() {

        searchClient.getSuggestionsHandler = { _, _, _, completion in
            completion(.failure(.noInternetConnection))
        }

        let expectedSuggestionPharma = String.fixture()
        pharmaDatabaseMock.suggestionsHandler = { _, _ in
            [expectedSuggestionPharma]
        }

        let expectation = self.expectation(description: "repository suggestions is completed")

        repository.suggestions(for: "spec") { suggestionsResult in
            if case .autocomplete(_, let value, _) = suggestionsResult.suggestions.first {
                XCTAssertEqual(value, self.library.autolinks.map { $0.phrase }.first)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.1)
    }
}
