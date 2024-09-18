//
//  SearchHistoryRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 03.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// @mockable
protocol SearchHistoryRepositoryType: AnyObject {
    var lastAddedHistoryItem: String? { get }

    func addSearchHistoryItem(_ item: String)
    func getSearchHistoryItems() -> [String]
}

final class SearchHistoryRepository: SearchHistoryRepositoryType {
    private let storage: Storage
    private let searchHistoryItemsMaxCount = 50
    private var searchHistoryItems: [SearchHistoryItem] {
        get {
            storage.get(for: .searchHistory) ?? []
        }
        set {
            storage.store(newValue, for: .searchHistory)
        }
    }

    var lastAddedHistoryItem: String? {
        getSearchHistoryItems().first
    }

    init(storage: Storage) {
        self.storage = storage
    }

    func addSearchHistoryItem(_ item: String) {
        let newSearchHistoryItem = SearchHistoryItem(query: item, date: Date())

        if searchHistoryItems.contains(newSearchHistoryItem) {
            searchHistoryItems.removeAll { $0 == newSearchHistoryItem }
            searchHistoryItems.insert(newSearchHistoryItem, at: 0)
            return
        }

        if searchHistoryItems.count == searchHistoryItemsMaxCount {
            var sortedSearchHistoryItems = searchHistoryItems.sorted { $0.date > $1.date }
            sortedSearchHistoryItems.removeLast()
            searchHistoryItems = sortedSearchHistoryItems + [newSearchHistoryItem]
        } else {
            searchHistoryItems.append(newSearchHistoryItem)
        }
    }

    func getSearchHistoryItems() -> [String] {
        searchHistoryItems
            .sorted { $0.date > $1.date }
            .map { $0.query }
    }
}

extension SearchHistoryRepository {
    struct SearchHistoryItem: Hashable, Codable {
        let query: String
        let date: Date

        static func == (lhs: SearchHistoryItem, rhs: SearchHistoryItem) -> Bool {
            lhs.query == rhs.query
        }
    }
}
