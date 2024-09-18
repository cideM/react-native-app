//
//  Tracker.Event.Search.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 19.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

// swiftlint:disable nesting

import Domain
import Foundation

extension Tracker.Event {

    enum Search {
        case searchCancelled(searchId: String,
                             searchTerm: String)

        case searchResultRefresh(searchId: String,
                                 searchTerm: String)
        case searchTextCleared

        case searchSessionStarted(searchSessionId: String,
                                  searchSessionQuery: String? = nil)

        case searchInputFieldFocused(currentValue: String,
                                     searchSessionId: String,
                                     searchSessionQuery: String? = nil)

        case searchQueryCommitted(fromSource: SearchQuerySource,
                                  instantTarget: SearchSuggestionItem?,
                                  queryValue: String?,
                                  searchSessionId: String,
                                  method: SearchQueryInputMethod)

        case searchResultsShown(didYouMean: String? = nil,
                                resultUuids: [String],
                                searchSessionId: String,
                                searchSessionQuery: String,
                                searchSessionDYM: String,
                                view: View)

        case searchFollowupQueriesShown(followupQuery: String,
                                        searchSessionId: String,
                                        searchSessionQuery: String,
                                        searchSessionDYM: String)

        case searchFollowupQuerySelected(followupQuery: String,
                                         searchSessionId: String,
                                         searchSessionQuery: String,
                                         searchSessionDYM: String)

        case searchResultsErrorShown(error: String,
                                     searchSessionId: String,
                                     searchSessionQuery: String,
                                     searchSessionDYM: String,
                                     view: View)

        case searchResultsViewChanged(newView: View,
                                      previousView: View,
                                      searchSessionId: String,
                                      searchSessionQuery: String,
                                      searchSessionDYM: String)

        case searchResultsMoreRequested(additionalNumberRequested: Int,
                                        currentResultCount: Int,
                                        searchSessionId: String,
                                        searchSessionQuery: String,
                                        searchSessionDYM: String,
                                        view: View)

        case searchResultSelected(fromView: View,
                                  searchSessionId: String,
                                  searchSessionQuery: String,
                                  searchSessionDYM: String,
                                  selectedIndex: Int,
                                  selectedSubIndex: Int?,
                                  targetUuid: String)

        case searchSuggestionApplied(currentInputValue: String,
                                     method: Method = .select,
                                     fromSuggestions: [SearchSuggestionItem],
                                     searchSessionId: String,
                                     selectedIndex: Int)

        case searchSuggestionsShown(forInputValue: String,
                                    currentInputValue: String,
                                    searchSessionId: String,
                                    suggestions: [SearchSuggestionItem])

        case searchOfflineSuggestionsShown(searchSessionId: String,
                                           searchSessionQuery: String,
                                           suggestions: [SearchSuggestionItem])

        case searchOfflineResultsShown(results: (PhrasionaryItem?, [SearchResultItem]),
                                       searchSessionId: String,
                                       searchSessionQuery: String,
                                       view: View)

        case searchOfflineResultSelected(fromResults: (PhrasionaryItem?, [SearchResultItem]),
                                         fromView: View,
                                         searchSessionId: String,
                                         searchSessionQuery: String,
                                         selectedIndex: Int,
                                         selectedSubIndex: Int)

        case searchOfflineSuggestionApplied(currentInputValue: String,
                                            fromSuggestions: [SearchSuggestionItem],
                                            searchSessionId: String,
                                            selectedIndex: Int)

        case searchOfflineQueryCommitted(fromSource: SearchQuerySource,
                                         instantTarget: SearchSuggestionItem?,
                                         queryValue: String?,
                                         searchSessionId: String,
                                         method: SearchQueryInputMethod)

        case searchFiltersShown(filtersMedia: [MediaFilter],
                                searchSessionId: String,
                                searchSessionQuery: String,
                                searchSessionDYM: String,
                                view: View)

        enum SearchQuerySource: String {
            case inputValue = "input_value"
            case instantResult = "instant_result"
            case querySuggestion = "query_suggestion"
            case searchHistory = "search_history"
        }

        enum SearchQueryInputMethod: String {
            case keyboard
            case dictation
        }

        enum Method: String {
            case select = "select"
            case useValue = "use_value"
        }

        enum SearchType: String {
            case all
            case article
            case pharma
            case media
            case guideline
        }

        struct View: Encodable {
            let name: SearchResultsViewName
            let filters: SearchResultsViewFilters

            init(name: SearchResultsViewName, mediaFilters: [String]) {
                self.name = name
                self.filters = SearchResultsViewFilters(media: .init(mediaType: mediaFilters))
            }

            func toDictionary() -> [String: Any] {
                let jsonEndoder = JSONEncoder()
                guard let jsonData = try? jsonEndoder.encode(self),
                      let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                    return [:]
                }
                return jsonDictionary
            }

            enum SearchResultsViewName: String, Encodable {
                case overview = "OVERVIEW"
                case guidelines = "GUIDELINES"
                case articles = "ARTICLES"
                case media = "MEDIA"
                case pharma = "PHARMA"
            }

            struct SearchResultsViewFilters: Encodable {
                let media: SearchResultsViewFiltersMedia

                struct SearchResultsViewFiltersMedia: Encodable {
                    let mediaType: [String]
                }
            }
        }
    }
}
