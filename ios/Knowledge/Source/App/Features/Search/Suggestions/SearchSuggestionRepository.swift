//
//  SearchSuggestionRepository.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 24.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import PharmaDatabase

/// @mockable
protocol SearchSuggestionRepositoryType: AnyObject {
    func suggestions(for text: String, completion: @escaping (SearchSuggestionResult) -> Void)
}

final class SearchSuggestionRepository: SearchSuggestionRepositoryType {
    private let searchClient: SearchClient
    private let libraryRepository: LibraryRepositoryType
    private let pharmaService: PharmaDatabaseApplicationServiceType?
    private let remoteConfigRepository: RemoteConfigRepositoryType
    private let appConfiguration: Configuration
    private let monitor: Monitoring = resolve()

    init(searchClient: SearchClient = resolve(),
         libraryRepository: LibraryRepositoryType = resolve(),
         pharmaService: PharmaDatabaseApplicationServiceType? = resolve(),
         remoteConfigRepository: RemoteConfigRepositoryType = resolve(),
         appConfiguration: Configuration = AppConfiguration.shared) {
        self.searchClient = searchClient
        self.libraryRepository = libraryRepository
        self.pharmaService = pharmaService
        self.remoteConfigRepository = remoteConfigRepository
        self.appConfiguration = appConfiguration
    }

    func suggestions(for text: String, completion: @escaping (SearchSuggestionResult) -> Void) {

        let completionHandler: Completion<[SearchSuggestionItem], NetworkError<EmptyAPIError>> = { [libraryRepository, monitor] result in
            switch result {
            case .success(let suggestions): completion(SearchSuggestionResult(resultType: .online, suggestions: suggestions))
            case .failure:

                var suggestions = Array(libraryRepository.library.autolinks
                    .filter { $0.phrase.lowercased().contains(text.lowercased()) }
                    .sorted { $0.score > $1.score }
                    .map { $0.phrase }
                    .prefix(25)) // We are showing the top 25 suggestions for a query when the user is offline

                do {
                    if let pharmaSuggestions = try self.pharmaService?.pharmaDatabase?.suggestions(for: text, max: 25) {
                        /// Creates a new array containing alternating elements of both source arrays
                        /// First element of the new array is the first object in "suggestoins"
                        /// Interleaving will happen as long as both arrays have sufficient items
                        /// Remaining elements of either array will be appended to the result
                        let minLength = min(suggestions.count, pharmaSuggestions.count)
                        suggestions = zip(suggestions, pharmaSuggestions).flatMap { [$0, $1] }
                            + suggestions.suffix(from: minLength)
                            + pharmaSuggestions.suffix(from: minLength)
                    }
                } catch {
                    monitor.error(error, context: .search)
                }
                completion(SearchSuggestionResult(resultType: .offline, suggestions: suggestions.map { .autocomplete(text: $0, value: $0, metadata: nil) }))
            }

        }

        switch appConfiguration.appVariant {
        case .wissen:

            searchClient.getSuggestions(for: text, resultTypes: [.article, .pharmaSubstance], timeout: remoteConfigRepository.requestTimeout, completion: completionHandler)
        case .knowledge:
            var types: [SearchSuggestionResultType] = [.article]
            if remoteConfigRepository.areMonographsEnabled {
                types.append(.pharmaMonograph)
            }
            searchClient.getSuggestions(for: text, resultTypes: types, timeout: remoteConfigRepository.requestTimeout, completion: completionHandler)
        }
    }
}
