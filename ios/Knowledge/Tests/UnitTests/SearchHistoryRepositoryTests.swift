//
//  SearchHistoryRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 03.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class SearchHistoryRepositoryTests: XCTestCase {

    var storage: Storage!
    var searchHistoryRepository: SearchHistoryRepositoryType!

    override func setUp() {
        storage = MemoryStorage()
        searchHistoryRepository = SearchHistoryRepository(storage: storage)
    }

    func testThatLastAddedHistoryItemReturnsTheLastItemAdded() {
        searchHistoryRepository.addSearchHistoryItem("spec_1")
        searchHistoryRepository.addSearchHistoryItem("spec_2")
        searchHistoryRepository.addSearchHistoryItem("spec_3")

        XCTAssertEqual(searchHistoryRepository.lastAddedHistoryItem, "spec_3")
    }

    func testThatAddingASearchItemToAnEmptyStorageAddsIt() {
        let searchItem: String = .fixture()

        searchHistoryRepository.addSearchHistoryItem(searchItem)

        let storedSearchHistoryItems: [SearchHistoryRepository.SearchHistoryItem]? = storage.get(for: .searchHistory)
        XCTAssertEqual(searchItem, storedSearchHistoryItems?.first?.query)
    }

    func testThatTryingToAddADuplicateSearchItemDoesNotAddIt() {
        let searchItem = "spec_1"
        searchHistoryRepository.addSearchHistoryItem(searchItem)

        searchHistoryRepository.addSearchHistoryItem(searchItem)

        let storedSearchHistoryItems: [SearchHistoryRepository.SearchHistoryItem]? = storage.get(for: .searchHistory)
        XCTAssertEqual(storedSearchHistoryItems?.count, 1)
    }

    func testThatTryingToAddAnItemToStorageThatHas50HistoryItemsDeletesTheOldestOneAndAddsTheNewOne() {
        for x in 0..<50 {
            searchHistoryRepository.addSearchHistoryItem("spec_\(x)")
        }
        let searchItem = "spec_50"

        searchHistoryRepository.addSearchHistoryItem(searchItem)

        let storedSearchHistoryItems: [SearchHistoryRepository.SearchHistoryItem]? = storage.get(for: .searchHistory)
        XCTAssertEqual(storedSearchHistoryItems?.count, 50)
        XCTAssert(searchHistoryRepository.getSearchHistoryItems().contains("spec_50"))
        XCTAssertFalse(searchHistoryRepository.getSearchHistoryItems().contains("spec_0"))
    }

    func testThatSearchHistoryItemsAreReturnedSortedByDate() {
        searchHistoryRepository.addSearchHistoryItem("spec_1")
        searchHistoryRepository.addSearchHistoryItem("spec_2")
        searchHistoryRepository.addSearchHistoryItem("spec_3")

        let storedHistoryItems = searchHistoryRepository.getSearchHistoryItems()

        XCTAssertEqual(storedHistoryItems, ["spec_3", "spec_2", "spec_1"])
    }
}
