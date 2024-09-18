//
//  SegmentTrackingSerializer+Search.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 19.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

extension EventSerializer {

    func name(for event: Tracker.Event.Search) -> String? {
        switch event {
        case .searchCancelled: return "search_cancelled"
        case .searchResultRefresh: return "search_result_refresh"
        case .searchTextCleared: return "search_text_cleared"
        // New search events
        case .searchSessionStarted: return "search_session_started"
        case .searchInputFieldFocused: return "search_input_field_focused"
        case .searchSuggestionsShown: return "search_suggestions_shown"
        case .searchSuggestionApplied: return "search_suggestion_applied"
        case .searchQueryCommitted: return "search_query_committed"
        case .searchResultsShown: return "search_results_shown"
        case .searchFollowupQueriesShown: return "search_followup_queries_shown"
        case .searchFollowupQuerySelected: return "search_followup_query_selected"
        case .searchResultsErrorShown: return "search_results_error_shown"
        case .searchResultsViewChanged: return "search_results_view_changed"
        case .searchResultsMoreRequested: return "search_results_more_requested"
        case .searchResultSelected: return "search_result_selected"
        case .searchOfflineSuggestionsShown: return "search_offline_suggestions_shown"
        case .searchOfflineResultsShown: return "search_offline_results_shown"
        case .searchOfflineResultSelected: return "search_offline_result_selected"
        case .searchOfflineSuggestionApplied: return "search_offline_suggestion_applied"
        case .searchOfflineQueryCommitted: return "search_offline_query_committed"
        case .searchFiltersShown: return "search_filters_shown"
        }
    }

    func parameters(for event: Tracker.Event.Search) -> [String: Any]? {
        let parameters = SegmentParameter.Container<SegmentParameter.Search>()
        switch event {
        case .searchCancelled(let searchId, let searchTerm):
            parameters.set(searchId, for: .searchId)
            parameters.set(searchTerm, for: .searchTerm)
        case .searchResultRefresh(let searchId, let searchTerm):
            parameters.set(searchId, for: .searchId)
            parameters.set(searchTerm, for: .searchTerm)
        case .searchTextCleared:
            return nil
        case .searchSessionStarted(searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery):
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
        case .searchInputFieldFocused(currentValue: let currentValue, searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery):
            parameters.set(currentValue, for: .currentValue)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
        case .searchSuggestionsShown(forInputValue: let forInputValue, currentInputValue: let currentInputValue, searchSessionId: let searchSessionId, suggestions: let suggestions):
            parameters.set(forInputValue, for: .forInputValue)
            parameters.set(currentInputValue, for: .currentInputValue)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(trackingData(for: suggestions), for: .suggestions)
        case .searchSuggestionApplied(currentInputValue: let currentInputValue, method: let method, fromSuggestions: let fromSuggestions, searchSessionId: let searchSessionId, selectedIndex: let selectedIndex):
            parameters.set(currentInputValue, for: .currentInputValue)
            parameters.set(method, for: .method)
            parameters.set(trackingData(for: fromSuggestions), for: .fromSuggestions)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(selectedIndex, for: .selectedIndex)
        case .searchQueryCommitted(fromSource: let fromSource, instantTarget: let instantTarget, queryValue: let queryValue, searchSessionId: let searchSessionId, let method):
            parameters.set(fromSource, for: .fromSource)
            parameters.set(trackingData(for: instantTarget), for: .instantTarget)
            parameters.set(queryValue, for: .queryValue)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(method, for: .inputMethod)
        case .searchResultsShown(didYouMean: let didYouMean, resultUuids: let resultUuids, searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery, searchSessionDYM: let searchSessionDYM, view: let view):
            parameters.set(didYouMean, for: .didYouMean)
            parameters.set(resultUuids, for: .resultUuids)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
            parameters.set(searchSessionDYM, for: .searchSessionDYM)
            parameters.set(view.toDictionary(), for: .view)
        case .searchFollowupQueriesShown(followupQuery: let followupQuery, searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery, searchSessionDYM: let searchSessionDYM):
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
            parameters.set(searchSessionDYM, for: .searchSessionDYM)
            parameters.set([object(for: followupQuery)], for: .followupQueries)
        case .searchFollowupQuerySelected(followupQuery: let followupQuery, searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery, searchSessionDYM: let searchSessionDYM):
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
            parameters.set(0, for: .selectedIndex)
            parameters.set(searchSessionDYM, for: .searchSessionDYM)
            parameters.set([object(for: followupQuery)], for: .fromQueries)
        case .searchResultsErrorShown(error: let error, searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery, searchSessionDYM: let searchSessionDYM, view: let view):
            parameters.set(error, for: .error)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
            parameters.set(searchSessionDYM, for: .searchSessionDYM)
            parameters.set(view.toDictionary(), for: .view)
        case .searchResultsViewChanged(newView: let newView, previousView: let previousView, searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery, searchSessionDYM: let searchSessionDYM):
            parameters.set(newView.toDictionary(), for: .newView)
            parameters.set(previousView.toDictionary(), for: .previousView)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
            parameters.set(searchSessionDYM, for: .searchSessionDYM)
        case .searchResultsMoreRequested(additionalNumberRequested: let additionalNumberRequested, currentResultCount: let currentResultCount, searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery, searchSessionDYM: let searchSessionDYM, view: let view):
            parameters.set(additionalNumberRequested, for: .additionalNumberRequested)
            parameters.set(currentResultCount, for: .currentResultCount)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
            parameters.set(searchSessionDYM, for: .searchSessionDYM)
            parameters.set(view.toDictionary(), for: .view)
        case .searchResultSelected(fromView: let fromView, searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery, searchSessionDYM: let searchSessionDYM, selectedIndex: let selectedIndex, selectedSubIndex: let selectedSubIndex, targetUuid: let targetUuid):
            parameters.set(fromView.toDictionary(), for: .fromView)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
            parameters.set(searchSessionDYM, for: .searchSessionDYM)
            parameters.set(selectedIndex, for: .selectedIndex)
            parameters.set(selectedSubIndex, for: .selectedSubIndex)
            parameters.set(targetUuid, for: .targetUuid)
        case .searchOfflineSuggestionsShown(searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery, suggestions: let suggestions):
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
            parameters.set(suggestions.map {
                switch $0 {
                case .autocomplete(_, let value, _): return value ?? ""
                case .instantResult(.article(_, let value, _, _)): return value ?? ""
                case .instantResult(.pharmaCard(_, let value, _, _)): return value ?? ""
                case .instantResult(.monograph(_, let value, _, _)): return value ?? ""
                }
            }, for: .suggestions)
        case .searchOfflineResultsShown(results: let results, searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery, view: let view):
            parameters.set(value(searchOfflineResultItems: results), for: .results)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
            parameters.set(view.toDictionary(), for: .view)
        case .searchOfflineResultSelected(fromResults: let fromResults, fromView: let fromView, searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery, selectedIndex: let selectedIndex, selectedSubIndex: let selectedSubIndex):
            parameters.set(value(searchOfflineResultItems: fromResults), for: .fromResults)
            parameters.set(fromView.toDictionary(), for: .fromView)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
            parameters.set(selectedIndex, for: .selectedIndex)
            parameters.set(selectedSubIndex, for: .selectedSubIndex)
        case .searchOfflineSuggestionApplied(currentInputValue: let currentInputValue, fromSuggestions: let fromSuggestions, searchSessionId: let searchSessionId, selectedIndex: let selectedIndex):
            parameters.set(currentInputValue, for: .currentInputValue)
            parameters.set(trackingData(for: fromSuggestions), for: .fromSuggestions)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(selectedIndex, for: .selectedIndex)
        case .searchOfflineQueryCommitted(fromSource: let fromSource, instantTarget: let instantTarget, queryValue: let queryValue, searchSessionId: let searchSessionId, let method):
            parameters.set(fromSource, for: .fromSource)
            parameters.set(trackingData(for: instantTarget), for: .instantTarget)
            parameters.set(queryValue, for: .queryValue)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(method, for: .inputMethod)
        case .searchFiltersShown(filtersMedia: let filtersMedia, searchSessionId: let searchSessionId, searchSessionQuery: let searchSessionQuery, searchSessionDYM: let searchSessionDYM, view: let view):
            parameters.set(trackingData(for: filtersMedia), for: .filtersMedia)
            parameters.set(searchSessionId, for: .searchSessionId)
            parameters.set(searchSessionQuery, for: .searchSessionQuery)
            parameters.set(searchSessionDYM, for: .searchSessionDYM)
            parameters.set(view.toDictionary(), for: .view)
        }
        return parameters.data
    }

    // TODO: - Remove json serialization after search tracking is migrated
    private func trackingData(for filters: [MediaFilter]) -> [String: Any] {
        var trackingData = [String: Any]()
        let arrayData: [Any] = filters.map { item in
            [
                "value": item.value,
                "label": item.label,
                "isActive": item.isActive,
                "matchingCount": item.matchingCount,
                "__typename": "SearchFilterValue"
            ]
        }
        trackingData["__typename"] = "SearchFiltersMedia"
        trackingData["mediaType"] = arrayData
        return trackingData
    }

    private func trackingData(for suggestions: [SearchSuggestionItem]) -> [Any] {
        let arrayData: [Any] = suggestions.compactMap { item in
            trackingData(for: item)
        }
        return arrayData
    }

    private func trackingData(for suggestionItem: SearchSuggestionItem?) -> [String: Any]? {
        guard let suggestionItem = suggestionItem else { return nil }
        switch suggestionItem {
        case .autocomplete(text: let text, value: let value, metadata: let metadata):
            return [
                "text": text as Any,
                "value": value as Any,
                "metadata": metadata as Any,
                "__typename": "SearchSuggestionQuery"
            ]
        case .instantResult(let instantResult):
            switch instantResult {
            case .article(text: let text, value: let value, deepLink: let deeplink, metadata: let metadata):
                return [
                    "text": text ?? "",
                    "value": value ?? "",
                    "metadata": metadata ?? "",
                    "__typename": "SearchSuggestionInstantResult",
                    "target": [
                        "__typename": "SearchTargetArticle",
                        "anchorId": deeplink.anchor?.value as Any,
                        "articleEid": deeplink.learningCard.value,
                        "particleEid": deeplink.particle?.value as Any
                    ]
                ]
            case .monograph(text: let text, value: let value, deepLink: let deeplink, metadata: let metadata):
                return [
                    "text": text ?? "",
                    "value": value ?? "",
                    "metadata": metadata ?? "",
                    "__typename": "SearchSuggestionInstantResult",
                    "target": [
                        "__typename": "SearchTargetPharmaMonograph",
                        "pharmaMonographId": deeplink.monograph.value
                    ]
                ]
            case .pharmaCard(text: let text, value: let value, deepLink: let deeplink, metadata: let metadata):
                return [
                    "text": text ?? "",
                    "value": value ?? "",
                    "metadata": metadata ?? "",
                    "__typename": "SearchSuggestionInstantResult",
                    "target": [
                        "__typename": "SearchTargetPharmaAgent",
                        "drugId": deeplink.drug?.value as? Any ?? "",
                        "pharmaAgentId": deeplink.substance.value
                    ]
                ]
            }
        }
    }

    private func value(searchOfflineResultItems: (phrasionary: PhrasionaryItem?, searchResultItems: [SearchResultItem])) -> [[String: String]] {

        var resultItems: [[String: String]] = [[:]]

        resultItems += searchOfflineResultItems.searchResultItems.enumerated().compactMap {index, item in
            switch item {
            case .article(let articleItem):
                return [
                    "article_id_\(index)": articleItem.deepLink.learningCard.value,
                    "title": articleItem.title
                ]
            case .pharma(let pharmaItem):
                return [
                    "article_id_\(index)": pharmaItem.substanceID.value,
                    "title": pharmaItem.title
                ]
            default: return nil
            }
        }

        return resultItems
    }

    private func value(for scope: SearchScope) -> String {
        switch scope {
        case .overview: return Tracker.Event.Search.SearchType.all.rawValue
        case .library: return Tracker.Event.Search.SearchType.article.rawValue
        case .pharma: return Tracker.Event.Search.SearchType.pharma.rawValue
        case .guideline: return Tracker.Event.Search.SearchType.guideline.rawValue
        case .media: return Tracker.Event.Search.SearchType.media.rawValue
        }
    }

    private func object(for followupQuery: String) -> [String: String] {
        // Tracking has setup its data model for potentiel "future requirements"
        // hence we need to wrap the data in a potential graphQL object
        // In future we shall receive such an object directly via backend
        // and forward it to tracking, for the time being we partly fake it
        [
          "__typename": "SearchFollowupQuery",
          "text": followupQuery,
          "value": followupQuery
        ]
    }
}

extension SegmentParameter {
    enum Search: String {
        case searchTerm = "search_term"
        case searchId = "search_id"
        case didYouMean = "didyoumean"
        case appliedDidYouMean = "applied_didyoumean"
        case searchSessionId = "search_session_id"
        case searchSessionQuery = "search_session_query"
        case searchSessionDYM = "search_session_dym"
        case currentValue = "current_value"
        case fromSource = "from_source"
        case instantTarget = "instant_target"
        case queryValue = "query_value"
        case forInputValue = "for_input_value"
        case currentInputValue = "current_input_value"
        case suggestions = "suggestions"
        case selectedIndex = "selected_index"
        case selectedSubIndex = "selected_subindex"
        case fromSuggestions = "from_suggestions"
        case view = "view"
        case newView = "new_view"
        case previousView = "previous_view"
        case results = "results"
        case error = "error"
        case additionalNumberRequested = "additional_number_requested"
        case currentResultCount = "current_result_count"
        case fromResults = "from_results"
        case fromView = "from_view"
        case method = "method"
        case followupQueries = "followup_queries"
        case fromQueries = "from_queries"
        case filtersMedia = "filters_media"
        case inputMethod = "input_device"
        case targetUuid = "target_uuid"
        case resultUuids = "result_uuids"
    }
}
