//
//  SearchPresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 23.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Networking
import Localization
import DesignSystem

/// @mockable
protocol SearchPresenterType: AnyObject {
    var view: SearchViewType? { get set }
    var lastSelectedSearchScope: SearchScope? { get }

    func navigate(to searchDeepLink: SearchDeeplink)
    func navigate(to searchDeepLink: UncommitedSearchDeeplink)
    func searchBarTextDidChange(query: String)
    func searchBarClearButtonTapped()
    func searchBarTextFieldTapped(text: String)
    func searchBarSearchButtonTapped(query: String)
    func didYouMeanResultTapped(searchTerm: String, didYouMean: String)
    func didSelect(searchItem: SearchResultItemViewData, at index: Int, subIndex: Int?)
    func didTapScope(_ scope: SearchScope, query: String)
    func dismissView(query: String)
    func contactUsButtonTapped()
    func didScrollToBottom(with scope: SearchScope)
    func didTapPhrasionaryTarget(at index: Int)
}

final class SearchPresenter: SearchPresenterType {

    private static let defaultResultTypeOrder: [SearchResultContentType] = [.article, .pharmaMonograph, .guideline, .media]

    private let coordinator: SearchCoordinatorType
    private let searchRepository: SearchRepositoryType
    private let searchSuggestionRepository: SearchSuggestionRepositoryType
    private let searchHistoryRepository: SearchHistoryRepositoryType
    private let userDataRepository: UserDataRepositoryType
    private let featureFlagRepository: FeatureFlagRepositoryType
    private var pharmaRepository: PharmaRepositoryType
    private let userDataClient: UserDataClient
    private var suggestionTimer: Timer?
    private let autocompleteTimerDelay: TimeInterval
    private let trackingProvider: TrackingType
    private let supportRequestFactory: SupportRequestFactory
    private let remoteConfigRepository: RemoteConfigRepositoryType
    private let appConfiguration: Configuration
    private let shortcutsService: ShortcutsServiceType
    private let shortcutsRepository: ShortcutsRepositoryType
    private let mediaRepository: MediaRepositoryType
    private let galleryTrackingProvider: GalleryAnalyticsTrackingProviderType
    private let monitor: Monitoring = resolve()

    private var queryText: String?
    private var queryMediaFilters: [String] = []
    private var searchResult: SearchResult?
    private var searchSuggestionResult: SearchSuggestionResult?
    private var uncommittedSearchDeeplinkToNavigate: UncommitedSearchDeeplink?
    internal var lastSelectedSearchScope: SearchScope?

    private static let numberOfSectionResultsInOverviewTab = 3
    private static let numberOfSectionResultsInOverviewTabForMedia = 5
    private static let pageSize = 10
    private var isFetchingAnExtraPage = false
    private let retrySearchRequestTimeout = TimeInterval(60)
    private lazy var searchSessionId: String = {
        UUID().uuidString
    }()
    private var isSearchSessionActive = false
    private let dictationObserver = DictationObserver()

    weak var view: SearchViewType? {
        didSet {
            historySearch()

            let userActivity = shortcutsService.userActivity(for: .search)
            view?.setUserActivity(userActivity)

            shortcutsRepository.increaseUsageCount(for: .search)
            offerAddingVoiceShortcutIfNeeded()
            trackSearchSessionStartedIfNeeded(with: "")
            if let uncommittedSearchDeeplinkToNavigate = self.uncommittedSearchDeeplinkToNavigate {
                self.uncommittedSearchDeeplinkToNavigate = nil
                navigate(to: uncommittedSearchDeeplinkToNavigate)
            }
        }
    }

    init(coordinator: SearchCoordinatorType,
         searchRepository: SearchRepositoryType = resolve(),
         searchSuggestionRepository: SearchSuggestionRepositoryType = resolve(),
         searchHistoryRepository: SearchHistoryRepositoryType = resolve(),
         userDataRepository: UserDataRepositoryType = resolve(),
         featureFlagRepository: FeatureFlagRepositoryType = resolve(),
         pharmaRepository: PharmaRepositoryType = resolve(),
         userDataClient: UserDataClient = resolve(),
         autocompleteTimerDelay: TimeInterval = 0.3,
         trackingProvider: TrackingType = resolve(),
         supportRequestFactory: SupportRequestFactory = resolve(),
         remoteConfigRepository: RemoteConfigRepositoryType = resolve(),
         appConfiguration: Configuration = AppConfiguration.shared,
         shortcutsService: ShortcutsServiceType = resolve(),
         shortcutsRepository: ShortcutsRepositoryType = resolve(),
         mediaRepository: MediaRepositoryType = resolve(),
         galleryTrackingProvider: GalleryAnalyticsTrackingProviderType = resolve()) {
        self.coordinator = coordinator
        self.searchRepository = searchRepository
        self.searchSuggestionRepository = searchSuggestionRepository
        self.searchHistoryRepository = searchHistoryRepository
        self.userDataRepository = userDataRepository
        self.featureFlagRepository = featureFlagRepository
        self.pharmaRepository = pharmaRepository
        self.userDataClient = userDataClient
        self.autocompleteTimerDelay = autocompleteTimerDelay
        self.trackingProvider = trackingProvider
        self.supportRequestFactory = supportRequestFactory
        self.remoteConfigRepository = remoteConfigRepository
        self.appConfiguration = appConfiguration
        self.shortcutsService = shortcutsService
        self.shortcutsRepository = shortcutsRepository
        self.mediaRepository = mediaRepository
        self.galleryTrackingProvider = galleryTrackingProvider
    }

    func searchBarTextDidChange(query: String) {
        queryText = query
        trackSearchSessionStartedIfNeeded(with: query)

        if query.isEmpty {
            historySearch()
            view?.hideOfflineHint()
        } else {
            suggestionSearch(for: query)
        }
    }

    func searchBarClearButtonTapped() {
        trackingProvider.track(.searchTextCleared)
    }

    func searchBarTextFieldTapped(text: String) {
        trackSearchInputFieldFocused(with: text)

        suggestionSearch(for: text) { [weak self] in
            self?.view?.hideNoResultView()
            self?.view?.hideDidYouMeanView()
        }
    }

    func searchBarSearchButtonTapped(query: String) {
        search(for: query)
        trackSearchQueryCommitted(with: query, fromSource: .inputValue)
    }

    func didYouMeanResultTapped(searchTerm: String, didYouMean: String) {
        trackDidYouMean(searchTerm: searchTerm, didYouMean: didYouMean, searchID: searchSessionId, tapped: true)
        searchBarSearchButtonTapped(query: "\"\(searchTerm)\"")
    }

    func didSelect(searchItem: SearchResultItemViewData, at index: Int, subIndex: Int?) {
        switch searchItem {
        case .history(let item):
            search(for: item)
            trackSearchQueryCommitted(with: item,
                                      fromSource: .searchHistory)
        case .autocomplete(let suggestedTerm, let query):
            search(for: suggestedTerm.value)
            trackSearchSuggestionsApplied(currentInputValue: query,
                                          selectedIndex: index,
                                          fromSuggestions: searchSuggestionResult?.suggestions)
            trackSearchQueryCommitted(with: suggestedTerm.value,
                                      fromSource: .querySuggestion,
                                      searchSuggestionResult: searchSuggestionResult)
        case .phrasionary:
            break
        case .article(let item, let query):
            if let subIndex { // Handle tapping a child result
                navigate(to: item.children[subIndex].deeplink)
            } else { // Handle tapping a main result
                navigate(to: .learningCard(item.deeplink))
            }

            let child = item.children[safe: subIndex]
            trackSearchResultSelected(query: query,
                                      selectedIndex: item.resultIndex,
                                      selectedSubIndex: child?.sectionIndex,
                                      targetUuid: child?.targetUuid ?? item.targetUuid)
            trackArticleSelected(articleId: item.deeplink.learningCard,
                                 referrer: .searchResults)
        case .pharma(let item, let query, _):
            pharmaRepository.selectPharmaSearchResult()
            coordinator.navigate(to: item.substanceID, drug: item.drugId)
            trackSearchResultSelected(query: query,
                                      selectedIndex: index,
                                      selectedSubIndex: subIndex,
                                      targetUuid: item.targetUuid)
        case .monograph(let item, let query):
            if let subIndex { // Handle tapping a child result
                navigate(to: item.children[subIndex].deeplink)
            } else { // Handle tapping a main result
                navigate(to: .monograph(item.deeplink))
            }
            let child = item.children[safe: subIndex]
            trackSearchResultSelected(query: query,
                                      selectedIndex: item.resultIndex,
                                      selectedSubIndex: child?.sectionIndex,
                                      targetUuid: child?.targetUuid ?? item.targetUuid)

        case .instantResult(let suggestedTerm, let query):
            var instatTarget: SearchSuggestionItem?

            switch suggestedTerm.type {
            case .article(let articleDeeplink, let trackingData):
                instatTarget = trackingData
                trackArticleSelected(articleId: articleDeeplink.learningCard,
                                     referrer: .instantResults)
                coordinator.navigate(to: articleDeeplink.withSearchSessionID(searchSessionId))
            case .pharmaCard(let deeplink, let trackingData):
                instatTarget = trackingData
                coordinator.navigate(to: deeplink.substance, drug: deeplink.drug)
            case .monograph(let deeplink, let trackingData):
                instatTarget = trackingData
                coordinator.navigate(to: deeplink)
            }
            trackSearchSuggestionsApplied(currentInputValue: query, selectedIndex: index, fromSuggestions: searchSuggestionResult?.suggestions)
            trackSearchQueryCommitted(with: suggestedTerm.attributedText.string, fromSource: .instantResult, instantTarget: instatTarget)

            // Use the text property of instant result to preserve capitalization
            if let strippedText = suggestedTerm.attributedText.string.htmlTagsStripped() {
                searchHistoryRepository.addSearchHistoryItem(strippedText)
            }
        case .guideline(guidelineSearchViewItem: let item, let query):
            guard let url = item.externalURL else { return }
            coordinator.openURLInternally(url)
            trackSearchResultSelected(query: query,
                                      selectedIndex: index,
                                      selectedSubIndex: subIndex,
                                      targetUuid: item.targetUuid)
        case .media:
            break
        case .mediaOverview:
            break
        }
    }

    func navigate(to deepLink: Deeplink) {
        switch deepLink {
        case .learningCard(let link):
            coordinator.navigate(to: link.withSearchSessionID(searchSessionId))
        case .pharmaCard(let link):
            coordinator.navigate(to: link.substance, drug: link.drug)
        case .search(let link, _):
            guard let link else { return }
            coordinator.navigate(to: link)
        case .uncommitedSearch(let link):
            coordinator.navigate(to: link)
        case .monograph(let link):
            coordinator.navigate(to: link)
        default: ()
        }
    }

    func didTapScope(_ scope: SearchScope, query: String) {
        scopeShouldChange(scope) { [weak self, query] canChange in
            guard let self = self else { return }

            if canChange {
                // Track scope change done by the user
                if let previousSearchScope = self.lastSelectedSearchScope {
                    self.trackSearchResultsViewChanged(previousScope: previousSearchScope,
                                                       newScope: scope,
                                                       query: query)
                }
                // Scope has already been selected in the view => no need to update it there
                self.scopeDidChange(scope, query: query)

            } else {
                // Revert scope to the last selected scope, if unavailable fallback to overview
                self.view?.changeSelectedScope(self.lastSelectedSearchScope ?? .overview)
            }
        }
    }

    private func setScopeIfPermitted(scope: SearchScope,
                                     query: String,
                                     searchResultTypeOrder: [SearchResultContentType]? = nil) {
        scopeShouldChange(scope) { [weak self, query] canChange in
            guard let self = self else { return }

            if canChange {
                // Set the view with the new scope
                self.view?.changeSelectedScope(scope)
                self.lastSelectedSearchScope = scope
                self.scopeDidChange(scope, query: query, searchResultTypeOrder: searchResultTypeOrder)
            } else {
                // Set the view with the last selected scope, if unavailable fallback to overview
                let previousScope = self.lastSelectedSearchScope ?? .overview
                self.view?.changeSelectedScope(previousScope)
                self.scopeDidChange(previousScope, query: query, searchResultTypeOrder: searchResultTypeOrder)
            }

        }
    }

    private func scopeDidChange(_ scope: SearchScope,
                                query: String,
                                searchResultTypeOrder: [SearchResultContentType]? = nil) {
        let sections = self.sections(for: scope,
                                     query: query,
                                     searchResultTypeOrder: searchResultTypeOrder ?? SearchPresenter.defaultResultTypeOrder)
        self.view?.showSections(sections,
                                searchTerm: query,
                                scope: scope)
        trackSearchResultsShown(query: query,
                                mediaFilters: queryMediaFilters,
                                scope: scope,
                                sections: sections)
        if case .media = scope {
            trackSearchFiltersShown(query: query, scope: scope)
        }

        lastSelectedSearchScope = scope

        guard sections.isEmpty == false else {
            self.view?.showNoResultView()
            return
        }

        self.view?.showDidYouMeanViewIfNeeded(searchTerm: query, didYouMean: searchResult?.correctedSearchTerm)

        if let didYouMean = searchResult?.correctedSearchTerm {
            trackDidYouMean(searchTerm: query, didYouMean: didYouMean, searchID: searchSessionId, tapped: false)
        }

    }

    private func scopeShouldChange(_ newScope: SearchScope, completion: @escaping (Bool) -> Void) {
        switch newScope {
        case .pharma:
            if appConfiguration.appVariant == .wissen,
               userDataRepository.hasConfirmedHealthCareProfession != true {
                view?.showDisclaimerDialog { [weak self] isConfirmed in
                    guard let self = self else { return }
                    if isConfirmed { // Disclaimer can not be taken back once accepted
                        self.userDataRepository.hasConfirmedHealthCareProfession = isConfirmed
                        self.userDataClient.setHealthcareProfession(isConfirmed: isConfirmed) { [weak self] result in
                            // Ignore any error: If the request fails The dialog will just come up again next time.
                            // This is sent here immediately and not synced via UserDataSynchronizer
                            // cause there is no timestamp for this property, so the synchronizer
                            // would always use the value from the web, which would then discard
                            // the choice the user made here. Just pushing it directly solves the issue partly.
                            // Please see "UserDataSynchronizer.getCurrentUserConfiguration()" for the other part.
                            switch result {
                            case .failure(let error):
                                self?.monitor.error(error, context: .search)
                            case .success:
                                break
                            }
                        }
                    }
                    completion(isConfirmed)
                }
            } else {
                completion(true)
            }
        default:
            return completion(true)
        }
    }

    func dismissView(query: String) {
        trackingProvider.track(.searchCancelled(searchId: searchSessionId, searchTerm: query))
        coordinator.stop(animated: true)
    }

    func contactUsButtonTapped() {
        coordinator.openURLInternally(appConfiguration.searchNoResultsFeedbackForm)
    }

    private func search(for newQuery: String) {
        queryText = newQuery
        // This function is called when searching with a new text query
        // So we should clear the media filters here
        queryMediaFilters = []
        // Invalidate the auto-suggestion timer as soon as the user taps search because we don't want to show the auto-suggestions anymore.
        suggestionTimer?.invalidate()
        mediaRepository.clearCache()
        guard !newQuery.isEmpty else { return }

        searchHistoryRepository.addSearchHistoryItem(newQuery)
        overviewSearch(for: newQuery,
                       mediaFilters: queryMediaFilters,
                       requestTimeout: remoteConfigRepository.requestTimeout)
    }

    private func overviewSearch(for query: String,
                                mediaFilters: [String] = [],
                                requestTimeout: TimeInterval,
                                forceScope: SearchScope? = nil,
                                completion: ( () -> Void)? = nil) {
        view?.hideKeyboard()
        view?.showIsLoading(true)
        view?.setSearchTextFieldText(query)

        searchRepository.overviewSearch(for: query, requestTimeout: requestTimeout) { [weak self] result in
            guard let self = self else { return }
            self.view?.showIsLoading(false)
            switch result {
            case .success(let searchResult):
                self.searchResult = searchResult
                let availableSearchScopes = self.searchScopes(for: searchResult)
                self.view?.showAvailableSearchScopes(availableSearchScopes)

                let isPharmaSpecificSearchResult = searchResult.searchResultOverviewSectionOrder?.firstIndex(of: .pharmaMonograph) == 0 || searchResult.searchResultOverviewSectionOrder?.firstIndex(of: .pharmaSubstance) == 0

                // Initialize correct scope based on the targetView specified by the search result
                var targetScope: SearchScope?
                if let searchResultsTargetScope = searchResult.searchResultsTargetScope {
                    switch searchResultsTargetScope {
                    case .overview:
                        targetScope = .overview
                    case .article:
                        targetScope = .library(itemCount: searchResult.searchArticleResultsTotalCount)
                    case .media:
                        targetScope = .media(itemCount: searchResult.searchMediaResultsTotalCount)
                    case .pharma:
                        targetScope = .pharma(itemCount: searchResult.searchPharmaResultsTotalCount ?? 0)
                    case .guideline:
                        targetScope = .guideline(itemCount: searchResult.searchGuidelineResultsTotalCount)
                    }
                }

                var selectedScope: SearchScope
                var searchResultTypeOrder: [SearchResultContentType]?

                // Selecting the correct scope:
                if let forceScope = forceScope,
                   availableSearchScopes.contains(where: { $0.isSameCase(forceScope) }) {
                    // FIRST: We check if there is an overriding scope  is returned by
                    // the backend and exists the available search scopes
                    selectedScope = forceScope

                } else if let targetScope = targetScope,
                          availableSearchScopes.contains(where: { $0.isSameCase(targetScope) }) {
                    // SECOND: We check if the targetView is returned by
                    // the backend and exists the available search scopes
                    selectedScope = targetScope

                } else if isPharmaSpecificSearchResult {
                    // THIRD: A/B test PHEX-1100 – We check for
                    // the pharma tab switching experiment only
                    // if the search was a pharma search
                    if self.featureFlagRepository.featureFlags.contains("search_pharma_tab"),
                       let pharmaResultCount = searchResult.searchPharmaResultsTotalCount {
                        // Group A – switch to the pharma tab
                        selectedScope = SearchScope.pharma(itemCount: pharmaResultCount)
                    } else if self.featureFlagRepository.featureFlags.contains("search_pharma_reranking") {
                        // Group B - resort the sections on the overview page so that pharma is higher
                        selectedScope = .overview
                        searchResultTypeOrder = searchResult.searchResultOverviewSectionOrder
                    } else {
                        // Control / Default
                        selectedScope = .overview
                    }
                } else if let previousScope = self.lastSelectedSearchScope,
                          availableSearchScopes.contains(where: { $0.isSameCase(previousScope) }) {
                    // FOURTH: We check that a scope has been selected previously
                    // and it exists in the available search scopes
                    selectedScope = previousScope
                } else {
                    // FIFTH: If none of the previous checks are true,
                    // we fallback to the overview scope
                    selectedScope = .overview
                }

                // Set scope and sections appropriatly
                self.setScopeIfPermitted(scope: selectedScope,
                                         query: query,
                                         searchResultTypeOrder: searchResultTypeOrder)

                switch searchResult.resultType {
                case .online:
                    self.view?.hideOfflineHint()
                case .offline:
                    let retryAction = { [weak self] in
                        guard let self = self else { return }
                        self.overviewSearch(for: query,
                                            mediaFilters: mediaFilters,
                                            requestTimeout: self.retrySearchRequestTimeout,
                                            forceScope: forceScope)
                        self.trackingProvider.track(.searchResultRefresh(searchId: self.searchSessionId, searchTerm: query))
                    }
                    self.view?.showOfflineHint(retryAction: retryAction)
                }
            case .failure(let error):
                self.view?.showNoResultView()
                self.trackSearchResultsErrorShown(for: error.localizedDescription, query: query, mediaFilters: mediaFilters, scope: self.lastSelectedSearchScope ?? .overview)
            }
            completion?()
        }
    }

    private func searchScopes(for searchResult: SearchResult) -> [SearchScope] {
        var availableScopes: [SearchScope] = [.overview]

        if searchResult.searchArticleResultsTotalCount > 0 {
            availableScopes.append(.library(itemCount: searchResult.searchArticleResultsTotalCount))
        }

        if let searchPharmaResultsTotalCount = searchResult.searchPharmaResultsTotalCount, searchPharmaResultsTotalCount > 0 {
            availableScopes.append(.pharma(itemCount: searchPharmaResultsTotalCount))
        }

        if searchResult.searchMediaResultsTotalCount > 0, !searchResult.searchMediaResultItems.isEmpty {
            availableScopes.append(.media(itemCount: searchResult.searchMediaResultsTotalCount))
        }

        if searchResult.searchGuidelineResultsTotalCount > 0 {
            availableScopes.append(.guideline(itemCount: searchResult.searchGuidelineResultsTotalCount))
        }
        return availableScopes
    }

    private func databaseType(for searchResult: SearchResult) -> DatabaseType {
        let databaseType: DatabaseType
        switch searchResult.resultType {
        case .online:
            databaseType = .online
        case .offline:
            databaseType = .offline
        }
        return databaseType
    }

    private func historySearch() {
        let historyItems = searchHistoryRepository.getSearchHistoryItems()
        let sections = [
            SearchResultSection(headerType: .default(title: L10n.Search.HistorySection.title), items: historyItems.map { SearchResultItemViewData.history($0) })
        ]

        view?.showSections(sections, searchTerm: "", scope: nil)
        view?.showAvailableSearchScopes([])
    }

    private func suggestionSearch(for query: String, completion: (() -> Void)? = nil) {
        suggestionTimer?.invalidate()
        suggestionTimer = Timer.scheduledTimer(withTimeInterval: autocompleteTimerDelay, repeats: false) { [weak self] _ in
            self?.searchSuggestionRepository.suggestions(for: query) { [weak self] result in
                guard let self = self else { return }

                guard let queryText = self.queryText, !queryText.isEmpty else {
                    self.historySearch()
                    completion?()
                    return
                }

                self.view?.showAvailableSearchScopes([])
                self.searchSuggestionResult = result
                let autocompleteSection = self.autocompleteSection(from: result, for: query)
                let instantResultsSection = self.instantResultsSection(from: result, for: query)

                let sections = [instantResultsSection, autocompleteSection].filter { !$0.items.isEmpty }
                self.view?.showSections(sections, searchTerm: query, scope: nil)

                self.trackSearchSuggestionsShown(forInputValue: query, currentInputValue: queryText, suggestions: result.suggestions)

                if result.resultType == .offline {
                    self.view?.showOfflineHint { [weak self] in
                        self?.suggestionSearch(for: query)
                    }
                } else {
                    self.view?.hideOfflineHint()
                }

                completion?()
            }
        }
    }

    private func autocompleteSection(from searchSuggestionResult: SearchSuggestionResult, for query: String) -> SearchResultSection {
        let autocompleteSection = SearchResultSection(headerType: .default(title: L10n.Search.Suggestions.Section.Title.autocomplete), items: searchSuggestionResult.suggestions.compactMap { [weak self] item in

            guard let self = self else { return nil }

            switch item {
            case .autocomplete(let text, let value, _):
                guard let text = text,
                        let attributedText = self.attributedText(from: text, query: query, resultType: searchSuggestionResult.resultType) else { return nil }

                return .autocomplete(suggestedTerm: AutocompleteViewItem(text: attributedText, value: value, trackingData: item), query: query)
            default: return nil
            }
        })

        return autocompleteSection
    }

    private func instantResultsSection(from searchSuggestionResult: SearchSuggestionResult, for query: String) -> SearchResultSection {
        let items: [SearchResultItemViewData] = searchSuggestionResult.suggestions.compactMap({ [weak self] item in
            switch item {
            case SearchSuggestionItem.instantResult(.article(let text, let value, let deeplink, _)):
                guard let text = text,
                      let attributedText = self?.attributedText(from: text, query: query, resultType: .online) else {
                    return nil
                }
                return .instantResult(suggestedTerm: InstantResultViewItem(attributedText: attributedText, value: value, type: .article(deeplink, trackingData: item)), query: query)
            case SearchSuggestionItem.instantResult(.pharmaCard(let text, let value, let deeplink, _)):
                guard let text = text, let attributedText = self?.attributedText(from: text, query: query, resultType: .online) else { return nil }
                return .instantResult(suggestedTerm: InstantResultViewItem(attributedText: attributedText, value: value, type: .pharmaCard(deeplink, trackingData: item)), query: query)
            case SearchSuggestionItem.instantResult(.monograph(let text, let value, let deeplink, _)):
                guard let text = text, let attributedText = self?.attributedText(from: text, query: query, resultType: .online) else { return nil }
                return .instantResult(suggestedTerm: InstantResultViewItem(attributedText: attributedText, value: value, type: .monograph(deeplink, trackingData: item)), query: query)
            default:
                return nil
            }
        })

        let instantResultsSection = SearchResultSection(headerType: .default(title: L10n.Search.Suggestions.Section.Title.instantResults), items: items.compactMap { $0 })

        return instantResultsSection
    }

    private func attributedText(from text: String, query: String, resultType: SearchSuggestionResult.SuggestionResultType) -> NSAttributedString? {
        switch resultType {
        case .online:
            return try? HTMLParser.attributedStringFromHTML(htmlString: text, with: AutocompleteTableViewCell.titleStyle)
        case .offline:
            let attributedSuggestion = NSMutableAttributedString(string: text, attributes: ThemeManager.currentTheme.searchSuggestionItemNormalTitleTextAttributes)

            let components = query.components(separatedBy: " ")

            components.forEach { component in
                let ranges = text.ranges(of: component, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive])

                ranges.forEach { range in
                    attributedSuggestion.addAttributes(ThemeManager.currentTheme.searchSuggestionItemBoldTitleTextAttributes, range: range)
                }
            }

            return attributedSuggestion
        }
    }

    private func searchResultItemViewData(for mediaItems: [SearchResultItem], indexOffset: Int, totalMediaCount: Int, query: String) -> SearchResultItemViewData {
        var mediaItems = mediaItems.enumerated().compactMap { index, item -> MediaSearchOverviewItem? in
            if case .media(let mediaItem) = item {
                let tappedIndex = index + indexOffset
                let itemTapHandler: (MediaSearchViewItem) -> Void = { [unowned self, tappedIndex] mediaViewItem in
                    self.searchMediaItemTapped(mediaViewItem: mediaViewItem)
                    self.trackSearchResultSelected(query: query,
                                                   selectedIndex: tappedIndex,
                                                   selectedSubIndex: nil,
                                                   targetUuid: mediaViewItem.targetUuid)
                }
                return .mediaViewItem(MediaSearchViewItem(
                    mediaId: mediaItem.mediaId,
                    title: mediaItem.title,
                    url: mediaItem.url,
                    externalAdditionType: mediaItem.externalAddition?.type,
                    category: mediaItem.category,
                    typeName: mediaItem.typeName,
                    targetUuid: mediaItem.targetUUID,
                    tapHandler: itemTapHandler,
                    imageLoader: mediaRepository.image))
            } else {
                return nil
            }
        }
        if totalMediaCount > 5 {
            let tapHandler: () -> Void = { [weak self] in
                self?.searchMediaViewMoreItemTapped(query: query)
            }
            mediaItems.append(.viewMoreItem(MediaSearchViewMoreItem(title: L10n.Search.SearchScope.Overview.ViewMore.title, tapHandler: tapHandler)))
        }

        return .mediaOverview(mediaSearchOverviewItems: mediaItems, query: query)
    }

    private func searchMediaViewMoreItemTapped(query: String) {
        guard let searchResult = searchResult else { return }

        let newScope = SearchScope.media(itemCount: searchResult.searchMediaResultsTotalCount)
        self.changeSelectedScope(newScope, query: query)
    }

    private func searchMediaItemTapped(mediaViewItem: MediaSearchViewItem) {
        if let externalAdditionType = mediaViewItem.externalAdditionType, externalAdditionType.hasPlaceholderImage {
            coordinator.navigate(to: ExternalAdditionIdentifier(value: mediaViewItem.mediaId))
        } else {
            let imageResourceIdentifier = ImageResourceIdentifier(value: mediaViewItem.mediaId)
            coordinator.navigate(to: imageResourceIdentifier)
        }
    }

    private func articleSearchResultItemViewData(for articleItem: ArticleSearchItem,
                                                 index: Int) -> ArticleSearchViewItem {
        var children = [ChildSearchResultViewItem]()

        for (sectionIndex, child) in articleItem.children.enumerated() {

            let childViewItems = articleSearchResultChildrenViewData(for: child,
                                                                     sectionIndex: sectionIndex,
                                                                     level: 1) // first childern are always at level 1
            children.append(contentsOf: childViewItems)
        }

        return ArticleSearchViewItem(title: articleItem.title,
                                     body: articleItem.body,
                                     deeplink: articleItem.deepLink,
                                     resultIndex: index,
                                     children: children,
                                     targetUuid: articleItem.targetUUID)
    }

    private func articleSearchResultChildrenViewData(for articleItem: ArticleSearchItem,
                                                     sectionIndex: Int,
                                                     level: Int) -> [ChildSearchResultViewItem] {
        var children = [ChildSearchResultViewItem]()
        let currentItem = ChildSearchResultViewItem(title: articleItem.title,
                                                    body: articleItem.body,
                                                    deeplink: .learningCard(articleItem.deepLink),
                                                    level: level,
                                                    sectionIndex: sectionIndex,
                                                    targetUuid: articleItem.targetUUID)
        children.append(currentItem)
        for child in articleItem.children {

            let childViewItems = articleSearchResultChildrenViewData(for: child,
                                                                     sectionIndex: sectionIndex,
                                                                     level: level + 1)
            children.append(contentsOf: childViewItems)
        }

        return children
    }

    private func monographSearchResultItemViewData(for monographItem: MonographSearchItem,
                                                   index: Int) -> MonographSearchViewItem {
        var children = [ChildSearchResultViewItem]()

        for (sectionIndex, child) in monographItem.children.enumerated() {

            let childViewItems = monographSearchResultChildrenViewData(for: child,
                                                                       sectionIndex: sectionIndex,
                                                                       level: 1) // first childern are always at level 1
            children.append(contentsOf: childViewItems)
        }

        return MonographSearchViewItem(title: monographItem.title,
                                       details: monographItem.details,
                                       deeplink: monographItem.deepLink,
                                       resultIndex: index,
                                       children: children,
                                       targetUuid: monographItem.targetUUID)
    }

    private func monographSearchResultChildrenViewData(for monographItem: MonographSearchItem,
                                                       sectionIndex: Int,
                                                       level: Int) -> [ChildSearchResultViewItem] {
        var children = [ChildSearchResultViewItem]()
        let body = (monographItem.details ?? []).reduce(into: String()) { result, string in result.append("<br>\(string)") }
        let currentItem = ChildSearchResultViewItem(title: monographItem.title,
                                                    body: body,
                                                    deeplink: .monograph(monographItem.deepLink),
                                                    level: level,
                                                    sectionIndex: sectionIndex,
                                                    targetUuid: monographItem.targetUUID)
        children.append(currentItem)
        for child in monographItem.children {

            let childViewItems = monographSearchResultChildrenViewData(for: child,
                                                                       sectionIndex: sectionIndex,
                                                                       level: level + 1)
            children.append(contentsOf: childViewItems)
        }

        return children
    }
    private func searchResultItemViewData(for item: SearchResultItem, resultIndex: Int, query: String, database: DatabaseType) -> [SearchResultItemViewData] {
        switch item {
        case .article(let articleItem):
            let articleViewItem = articleSearchResultItemViewData(for: articleItem, index: resultIndex)
            return  [.article(articleSearchViewItem: articleViewItem, query: query)]

        case .pharma(let pharmaItem):
            let pharmaViewItem = PharmaSearchViewItem(item: pharmaItem)
            return [.pharma(pharmaSearchViewItem: pharmaViewItem, query: query, database: database)]

        case .monograph(let monographItem):
            let monographViewItem = monographSearchResultItemViewData(for: monographItem, index: resultIndex)
            return [.monograph(item: monographViewItem, query: query)]

        case .guideline(let guideline):
            let guidelineViewItem = GuidelineSearchViewItem(item: guideline, indexInfo: .init(index: resultIndex, subIndex: nil))
            return [.guideline(guidelineSearchViewItem: guidelineViewItem, query: query)]

        case .media(let mediaItem):
            let itemTapHandler: (MediaSearchViewItem) -> Void = { [unowned self, resultIndex] mediaViewItem in
                self.searchMediaItemTapped(mediaViewItem: mediaViewItem)
                self.trackSearchResultSelected(query: query, selectedIndex: resultIndex, selectedSubIndex: nil, targetUuid: mediaViewItem.targetUuid)
            }
            let mediaViewItem = MediaSearchViewItem(
                mediaId: mediaItem.mediaId,
                title: mediaItem.title,
                url: mediaItem.url,
                externalAdditionType: mediaItem.externalAddition?.type,
                category: mediaItem.category,
                typeName: mediaItem.typeName,
                targetUuid: mediaItem.targetUUID,
                tapHandler: itemTapHandler,
                imageLoader: mediaRepository.image)
            return [.media(mediaSearchViewItem: mediaViewItem, query: query)]
        }
    }

    func navigate(to searchDeepLink: UncommitedSearchDeeplink) {
        if let view = view {
            view.setSearchTextFieldText(searchDeepLink.initialQuery)
            searchBarTextDidChange(query: searchDeepLink.initialQuery)
            queryMediaFilters = [searchDeepLink.initialFilter].compactMap { $0 }
        } else {
            self.uncommittedSearchDeeplinkToNavigate = searchDeepLink
        }
    }

    func navigate(to searchDeepLink: SearchDeeplink) {
        queryText = searchDeepLink.query
        view?.setSearchTextFieldText(searchDeepLink.query)

        let scope: SearchScope
        switch searchDeepLink.type {
        case .all:
            scope = .overview
        case .article:
            scope = .library(itemCount: 0)
        case .pharma:
            scope = .pharma(itemCount: 0)
        case .guideline:
            scope = .guideline(itemCount: 0)
        case .media:
            scope = .media(itemCount: 0)
        }

        queryMediaFilters = [searchDeepLink.filter].compactMap { $0 }

        trackSearchSessionStartedIfNeeded(with: searchDeepLink.query)
        trackSearchQueryCommitted(with: searchDeepLink.query, fromSource: .inputValue)

        overviewSearch(for: searchDeepLink.query, requestTimeout: remoteConfigRepository.requestTimeout, forceScope: scope) { [weak self] in
            // When the search deeplink contains a media filter,
            // we must perform an overview search without any filters first,
            // then do another media-only search with the filter applied.
            // This is because we need the media results in the overview page
            // to remain unfiltered. And the results in the media section will
            // be filtered accourding to the filter in the deep link.
            guard let self = self,
                  searchDeepLink.type == .media,
                  !self.queryMediaFilters.isEmpty else { return }
            self.fetchFreshMedia(queryText: searchDeepLink.query, mediaFilters: self.queryMediaFilters, scrolledToSelectedFilter: true, scope: scope)
        }

    }

    // Only called by the handlers for the "All" buttons in the overview sections
    private func changeSelectedScope(_ newScope: SearchScope, query: String) {
        guard let searchResult = searchResult else { return }

        self.view?.changeSelectedScope(newScope)
        let newSections = self.sections(for: newScope, query: query)
        view?.showSections(newSections, searchTerm: query, scope: newScope)
        view?.showDidYouMeanViewIfNeeded(searchTerm: query, didYouMean: searchResult.correctedSearchTerm)
        if let didYouMean = searchResult.correctedSearchTerm {
            trackDidYouMean(searchTerm: query, didYouMean: didYouMean, searchID: searchSessionId, tapped: false)
        }
    }

    func didScrollToBottom(with scope: SearchScope) {
        guard
            !isFetchingAnExtraPage,
            let queryText = self.queryText,
            let searchResult = self.searchResult,
            case .online = searchResult.resultType else { return }

        switch scope {
        case .library:
            articleFetchMore(queryText: queryText, searchResult: searchResult, scope: scope)
            trackSearchResultsMoreRequested(query: queryText, scope: scope, additionalNumberRequested: SearchPresenter.pageSize, currentResultCount: searchResult.searchArticleResultItems.count)
        case .guideline:
            guidelineFetchMore(queryText: queryText, searchResult: searchResult, scope: scope)
            trackSearchResultsMoreRequested(query: queryText, scope: scope, additionalNumberRequested: SearchPresenter.pageSize, currentResultCount: searchResult.searchGuidelineResultItems.count)
        case .pharma:
            pharmaMonographFetchMore(queryText: queryText, searchResult: searchResult, scope: scope)
            trackSearchResultsMoreRequested(query: queryText, scope: scope, additionalNumberRequested: SearchPresenter.pageSize, currentResultCount: searchResult.searchPharmaResultItems.count)
        case .media:
            mediaFetchMore(queryText: queryText, mediaFilters: queryMediaFilters, searchResult: searchResult, scope: scope)
            trackSearchResultsMoreRequested(query: queryText, scope: scope, additionalNumberRequested: SearchPresenter.pageSize, currentResultCount: searchResult.searchMediaResultItems.count)
        case .overview: break
        }
    }

    func didTapPhrasionaryTarget(at index: Int) {
        guard let searchResult = searchResult,
              let target = searchResult.phrasionary?.targets[safe: index] else { return }
        switch target {
        case .article(let articleItem):
            self.coordinator.navigate(to: articleItem.deepLink)

            // If available, the phrasionary is alway the first result
            self.trackSearchResultSelected(query: self.queryText ?? "",
                                            selectedIndex: 0,
                                           selectedSubIndex: index,
                                           targetUuid: target.targetUUID)
        default: break
        }
    }
}

private extension SearchPresenter {
    func sections(for scope: SearchScope?, query: String, searchResultTypeOrder: [SearchResultContentType] = SearchPresenter.defaultResultTypeOrder) -> [SearchResultSection] {
        let sections: [SearchResultSection]
        switch scope {
        case .overview, nil:
            sections = sectionsForOverviewScope(query: query, searchResultTypeOrder: searchResultTypeOrder)
        case .library:
            sections = sectionsForArticleScope(query: query)
        case .pharma:
            sections = sectionsForPharmaScope(query: query)
        case .guideline:
            sections = sectionsForGuidelineScope(query: query)
        case .media:
            sections = sectionsForMediaScope(query: query)
        }
        return sections
    }

    func sectionsForOverviewScope(query: String, searchResultTypeOrder: [SearchResultContentType]) -> [SearchResultSection] {
        guard searchResultTypeOrder.count == 4 else { // this is for now just a safety measure since we only want to keep it for the A/B test anyways
            return sectionsForOverviewScope(query: query, searchResultTypeOrder: SearchPresenter.defaultResultTypeOrder)
        }

        var allSections: [SearchResultSection] = []
        var resultCount = 0

        // Always try to add phrasionary item first
        let (section, itemCount) = overviewPhrasionarySection(query: query)

        if let section = section {
            allSections.append(section)
            resultCount += itemCount
        }

        // Then add sections accourding to searchResultTypeOrder
        for sectionType in searchResultTypeOrder {
            var sectionInfo: (section: SearchResultSection, resultCount: Int)?

            switch sectionType {
            case .article:
                sectionInfo = overviewArticleSection(query: query, indexOffset: resultCount)
            case .pharmaSubstance, .pharmaMonograph:
                sectionInfo = overviewPharmaSection(query: query, indexOffset: resultCount)
            case .guideline:
                sectionInfo = overviewGuidelineSection(query: query, indexOffset: resultCount)
            case .media:
                sectionInfo = overviewMediaSection(query: query, indexOffset: resultCount)
            case .phrasionary: break // we allways add the phrasionary first
            case .libraryList, .course: break // we don't support the library list or courses yet
            }

            // Only add sections that countain some items
            if let sectionInfo = sectionInfo, sectionInfo.resultCount > 0 {
                allSections.append(sectionInfo.section)
                resultCount += sectionInfo.resultCount
            }
        }

        return allSections
    }

    func overviewPhrasionarySection(query: String) -> (section: SearchResultSection?, resultCount: Int) {
        guard let searchResult = searchResult else { return (SearchResultSection(headerType: nil, items: []), 0) }

        let phrasionarySection: SearchResultSection?
        if let phrasionary = searchResult.phrasionary {
            let htmlAttributes = HTMLParser.Attributes(normal: .attributes(style: .paragraphSmallBold, with: [.color(.textAccent)]),
                                                       bold: .attributes(style: .paragraphSmallBold, with: [.color(.textAccent)]),
                                                       italic: .attributes(style: .paragraphSmall, with: [.color(.textAccent), .italic]))
            let targets: [NSAttributedString] = phrasionary.targets.compactMap { target in
                switch target {
                case .article(let articleItem):
                    return try? HTMLParser.attributedStringFromHTML(htmlString: articleItem.title, with: htmlAttributes)
                default: return nil
                }
            }
            let phrasionaryViewData = PhrasionaryView.ViewData(title: phrasionary.title,
                                                               subtitle1: phrasionary.synonyms.joined(separator: ". "),
                                                               subtitle2: phrasionary.etymology,
                                                               body: phrasionary.body, targets: targets)
            let sectionItemViewData = SearchResultItemViewData.phrasionary(phrasionary: phrasionaryViewData)
            phrasionarySection = SearchResultSection(headerType: nil, items: [sectionItemViewData])
        } else {
            phrasionarySection = nil
        }
        // resultCount is 0 if there is no phrasionary and 1 if there is one
        return (phrasionarySection, phrasionarySection == nil ? 0 : 1)
    }

    func overviewArticleSection(query: String, indexOffset: Int) -> (section: SearchResultSection, resultCount: Int) {
        guard let searchResult = searchResult else { return (SearchResultSection(headerType: nil, items: []), 0) }

        let databaseType = self.databaseType(for: searchResult)

        let articleItems = Array(searchResult.searchArticleResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTab))
        let articleItemsViewData: [SearchResultItemViewData] = articleItems.enumerated().flatMap { index, item in
            self.searchResultItemViewData(for: item, resultIndex: index + indexOffset, query: query, database: databaseType)
        }
        let articleSectionHeaderData = SearchResultSection.SearchResultHeaderData(iconImage: Asset.article, title: L10n.Search.SearchScope.Library.title, informationImage: nil, buttonTitle: "\(L10n.Search.OverviewHeader.Title.all) (\(searchResult.searchArticleResultsTotalCount))") { [weak self] in
            let newScope = SearchScope.library(itemCount: searchResult.searchArticleResultsTotalCount)
            self?.changeSelectedScope(newScope, query: query)
        }
        let articleSection = SearchResultSection(headerType: .searchResult(data: articleSectionHeaderData), items: articleItemsViewData)

        // The resultCount is the number of articles before flattening the results
        return (articleSection, articleItems.count)
    }

    func overviewPharmaSection(query: String, indexOffset: Int) -> (section: SearchResultSection, resultCount: Int) {
        guard
            let searchResult = searchResult,
            let searchPharmaResultsTotalCount = searchResult.searchPharmaResultsTotalCount
        else {
            return (SearchResultSection(headerType: nil, items: []), 0)
        }

        let databaseType = self.databaseType(for: searchResult)

        let pharmaItems = Array(searchResult.searchPharmaResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTab))
        let pharmaItemsViewData: [SearchResultItemViewData] = pharmaItems.enumerated().flatMap { index, item in
            self.searchResultItemViewData(for: item, resultIndex: index + indexOffset, query: query, database: databaseType)
        }

        let pharmaSectionHeaderData = SearchResultSection.SearchResultHeaderData(iconImage: Asset.Icon.pillIcon, title: L10n.Search.SearchScope.Pharma.title, informationImage: nil, buttonTitle: "\(L10n.Search.OverviewHeader.Title.all) (\(searchPharmaResultsTotalCount))") { [weak self] in
            let newScope = SearchScope.pharma(itemCount: searchPharmaResultsTotalCount)

            self?.scopeShouldChange(newScope) { [weak self] shouldChange in
                if shouldChange {
                    self?.changeSelectedScope(newScope, query: query)
                }
            }
        }
        let pharmaSection = SearchResultSection(headerType: .searchResult(data: pharmaSectionHeaderData), items: pharmaItemsViewData)

        // The resultCount is the number of pharma items
        return (pharmaSection, pharmaItems.count)
    }

    func overviewGuidelineSection(query: String, indexOffset: Int) -> (section: SearchResultSection, resultCount: Int) {
        guard
            let searchResult = searchResult
        else {
            return (SearchResultSection(headerType: nil, items: []), 0)
        }

        let databaseType = self.databaseType(for: searchResult)

        let guidelineItems = Array(searchResult.searchGuidelineResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTab))

        let guidelineItemsViewData: [SearchResultItemViewData] = guidelineItems.enumerated().flatMap { index, item in
            self.searchResultItemViewData(for: item, resultIndex: index + indexOffset, query: query, database: databaseType)
        }

        let guidelinesSectionHeaderData = SearchResultSection.SearchResultHeaderData(iconImage: Asset.Icon.layers, title: L10n.Search.SearchScope.Guideline.title, informationImage: nil, buttonTitle: "\(L10n.Search.OverviewHeader.Title.all) (\(searchResult.searchGuidelineResultsTotalCount))") { [weak self] in
            let newScope = SearchScope.guideline(itemCount: searchResult.searchGuidelineResultsTotalCount)
            self?.changeSelectedScope(newScope, query: query)
        }
        let guidelineSection = SearchResultSection(headerType: .searchResult(data: guidelinesSectionHeaderData), items: guidelineItemsViewData)

        // The resultCount is the number of guideline items
        return (guidelineSection, guidelineItems.count)
    }

    private func overviewMediaSection(query: String, indexOffset: Int) -> (section: SearchResultSection, resultCount: Int) {
        guard
            let searchResult = searchResult
        else {
            return (SearchResultSection(headerType: nil, items: []), 0)
        }

        let mediaItem = Array(searchResult.searchMediaOverviewResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTabForMedia))

        let mediaOverviewViewData = self.searchResultItemViewData(for: mediaItem, indexOffset: indexOffset, totalMediaCount: searchResult.searchMediaResultsTotalCount, query: query)

        let mediaSectionHeaderData = SearchResultSection.SearchResultHeaderData(iconImage: Asset.Icon.media, title: L10n.Search.SearchScope.Media.title, informationImage: nil, buttonTitle: "\(L10n.Search.OverviewHeader.Title.all) (\(searchResult.searchMediaResultsTotalCount))") { [weak self] in
            let newScope = SearchScope.media(itemCount: searchResult.searchMediaResultsTotalCount)
            self?.changeSelectedScope(newScope, query: query)
        }
        if searchResult.searchMediaResultsTotalCount > 0, !searchResult.searchMediaOverviewResultItems.isEmpty {
            return (SearchResultSection(headerType: .searchResult(data: mediaSectionHeaderData), items: [mediaOverviewViewData]), mediaItem.count)
        } else {
            return (SearchResultSection(headerType: .searchResult(data: mediaSectionHeaderData), items: []), 0)
        }
    }

    private func sectionsForArticleScope(query: String) -> [SearchResultSection] {
        guard let searchResult = searchResult else { return [] }

        let databaseType = self.databaseType(for: searchResult)
        let articleItems: [SearchResultItemViewData] = searchResult.searchArticleResultItems.enumerated().flatMap { index, item in
            self.searchResultItemViewData(for: item, resultIndex: index, query: query, database: databaseType)
        }
        let sections = [SearchResultSection(headerType: nil, items: articleItems)]

        return sections
    }

    private func sectionsForMediaScope(query: String) -> [SearchResultSection] {
        guard let searchResult = searchResult else { return [] }

        let databaseType = self.databaseType(for: searchResult)
        let mediaItems = searchResult.searchMediaResultItems.enumerated().flatMap { index, item in self.searchResultItemViewData(for: item, resultIndex: index, query: query, database: databaseType) }

        let filterTapClosure: (SearchFilterViewItem) -> Void = { [weak self] filter in

            var mediaFilters = [String]()
            if filter.isActive {
                mediaFilters = [filter.value]
            }
            self?.fetchFreshMedia(queryText: query, mediaFilters: mediaFilters, scrolledToSelectedFilter: false, scope: .media(itemCount: filter.count))
        }
        let filtersViewData = searchResult.searchMediaFiltersResult.filters.map { SearchFilterViewItem(name: $0.label, value: $0.value, count: $0.matchingCount, isActive: $0.isActive, tapClosure: filterTapClosure) }
        let sections = [SearchResultSection(headerType: .mediaResult(filters: filtersViewData), items: mediaItems)]

        return sections
    }

    private func sectionsForGuidelineScope(query: String) -> [SearchResultSection] {
        guard let searchResult = searchResult else { return [] }

        let databaseType = self.databaseType(for: searchResult)
        let guidelineItems = searchResult.searchGuidelineResultItems.enumerated().flatMap { index, item in self.searchResultItemViewData(for: item, resultIndex: index, query: query, database: databaseType) }
        let sections = [SearchResultSection(headerType: nil, items: guidelineItems)]

        return sections
    }

    func sectionsForPharmaScope(query: String) -> [SearchResultSection] {
        guard let searchResult = searchResult else { return [] }

        let databaseType = self.databaseType(for: searchResult)
        let pharmaItems = searchResult.searchPharmaResultItems.enumerated().flatMap { index, item in self.searchResultItemViewData(for: item, resultIndex: index, query: query, database: databaseType) }
        let sections = [SearchResultSection(headerType: nil, items: pharmaItems)]

        return sections
    }
}

private extension SearchPresenter {
    func offerAddingVoiceShortcutIfNeeded() {
        if shortcutsRepository.shouldOfferAddingVoiceShortcut(for: .search) {
            let message = PresentableMessage(title: L10n.Shortcuts.Search.AddToSiriAlert.title, description: L10n.Shortcuts.Search.AddToSiriAlert.body(L10n.Shortcuts.Search.suggestedInvocationPhrase), logLevel: .info)
            let notNowAction = MessageAction(title: L10n.Shortcuts.Search.AddToSiriAlert.no, style: .normal) {
                self.shortcutsRepository.addingVoiceShortcutWasOffered(for: .search)
                self.trackingProvider.track(.searchSiriShortcutDialogDeclined)
                return true
            }
            let addToSiriAction = MessageAction(title: L10n.Shortcuts.Search.AddToSiriAlert.addToSiriButtonTitle, style: .primary) { [weak self] in
                self?.coordinator.navigateToAddVoiceSearchShortcut()
                self?.shortcutsRepository.addingVoiceShortcutWasOffered(for: .search)
                self?.trackingProvider.track(.searchSiriShortcutDialogAccepted)
                return true
            }

            view?.presentMessage(message, actions: [notNowAction, addToSiriAction])

            trackingProvider.track(.searchSiriShortcutDialogShown)
        }
    }
}

private extension SearchPresenter {
    func articleFetchMore(queryText: String, searchResult: SearchResult, scope: SearchScope) {
        guard searchResult.searchArticleResultPageInfo?.hasNextPage == true else { return }

        isFetchingAnExtraPage = true

        searchRepository.fetchArticleSearchResultPage(for: queryText, limit: SearchPresenter.pageSize, requestTimeout: remoteConfigRepository.requestTimeout, after: searchResult.searchArticleResultPageInfo?.endCursor) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let page):
                if let page = page {
                    let searchResultItems = page.elements.map { SearchResultItem.article($0) }
                    let pageInfo = SearchOverviewResult.PageInfo(endCursor: page.nextPage, hasNextPage: page.hasNextPage)
                    self.searchResult?.appendArticleItems(searchResultItems, newPageInfo: pageInfo)

                    let sections = self.sections(for: scope, query: queryText)
                    self.view?.showSections(sections, searchTerm: queryText, scope: scope)
                }
            case .failure: break
            }

            self.isFetchingAnExtraPage = false
        }
    }

    func pharmaMonographFetchMore(queryText: String, searchResult: SearchResult, scope: SearchScope) {
        switch appConfiguration.appVariant {
        case .wissen:
            pharmaFetchMore(queryText: queryText, searchResult: searchResult, scope: scope)
        case .knowledge:
            monographFetchMore(queryText: queryText, searchResult: searchResult, scope: scope)
        }
    }

    func pharmaFetchMore(queryText: String, searchResult: SearchResult, scope: SearchScope) {
        guard searchResult.searchPharmaResultPageInfo?.hasNextPage == true else { return }

        isFetchingAnExtraPage = true

        searchRepository.fetchPharmaSearchResultPage(for: queryText, limit: SearchPresenter.pageSize, requestTimeout: remoteConfigRepository.requestTimeout, after: searchResult.searchPharmaResultPageInfo?.endCursor) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let page):
                if let page = page {
                    let searchResultItems = page.elements.map { SearchResultItem.pharma($0) }
                    let pageInfo = SearchOverviewResult.PageInfo(endCursor: page.nextPage, hasNextPage: page.hasNextPage)
                    self.searchResult?.appendPharmaItems(searchResultItems, newPageInfo: pageInfo)

                    let sections = self.sections(for: scope, query: queryText)
                    self.view?.showSections(sections, searchTerm: queryText, scope: scope)
                }
            case .failure: break
            }

            self.isFetchingAnExtraPage = false
        }
    }

    func monographFetchMore(queryText: String, searchResult: SearchResult, scope: SearchScope) {
        guard searchResult.searchPharmaResultPageInfo?.hasNextPage == true else { return }

        isFetchingAnExtraPage = true

        searchRepository.fetchMonographSearchResultPage(for: queryText, limit: SearchPresenter.pageSize, requestTimeout: remoteConfigRepository.requestTimeout, after: searchResult.searchPharmaResultPageInfo?.endCursor) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let page):
                if let page = page {
                    let searchResultItems = page.elements.map { SearchResultItem.monograph($0) }
                    let pageInfo = SearchOverviewResult.PageInfo(endCursor: page.nextPage, hasNextPage: page.hasNextPage)
                    self.searchResult?.appendPharmaItems(searchResultItems, newPageInfo: pageInfo)

                    let sections = self.sections(for: scope, query: queryText)
                    self.view?.showSections(sections, searchTerm: queryText, scope: scope)
                }
            case .failure: break
            }

            self.isFetchingAnExtraPage = false
        }
    }

    func guidelineFetchMore(queryText: String, searchResult: SearchResult, scope: SearchScope) {
        guard searchResult.searchGuidelineResultPageInfo?.hasNextPage == true else { return }

        isFetchingAnExtraPage = true

        searchRepository.fetchGuidelineSearchResultPage(for: queryText, limit: SearchPresenter.pageSize, requestTimeout: remoteConfigRepository.requestTimeout, after: searchResult.searchGuidelineResultPageInfo?.endCursor) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let page):
                if let page = page {
                    let searchResultItems = page.elements.map { SearchResultItem.guideline($0) }
                    let pageInfo = SearchOverviewResult.PageInfo(endCursor: page.nextPage, hasNextPage: page.hasNextPage)
                    self.searchResult?.appendGuidelineItems(searchResultItems, newPageInfo: pageInfo)

                    let sections = self.sections(for: scope, query: queryText)
                    self.view?.showSections(sections, searchTerm: queryText, scope: scope)
                }
            case .failure: break
            }

            self.isFetchingAnExtraPage = false
        }
    }

    func mediaFetchMore(queryText: String, mediaFilters: [String], searchResult: SearchResult, scope: SearchScope) {
        guard searchResult.searchMediaResultPageInfo?.hasNextPage == true else { return }

        isFetchingAnExtraPage = true
        searchRepository.fetchMediaSearchResultPage(for: queryText, mediaFilters: mediaFilters, limit: SearchPresenter.pageSize, requestTimeout: remoteConfigRepository.requestTimeout, after: searchResult.searchMediaResultPageInfo?.endCursor) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success((let page, let filters)):
                if let page = page {
                    let searchResultItems = page.elements.map { SearchResultItem.media($0) }
                    let pageInfo = SearchOverviewResult.PageInfo(endCursor: page.nextPage, hasNextPage: page.hasNextPage)
                    self.searchResult?.appendMediaItems(searchResultItems, newPageInfo: pageInfo)
                    self.searchResult?.setMediaFilters(result: filters)
                    let sections = self.sections(for: scope, query: queryText)
                    self.view?.showSections(sections, searchTerm: queryText, scope: scope)
                }
            case .failure: break
            }

            self.isFetchingAnExtraPage = false
        }
    }

    func fetchFreshMedia(queryText: String, mediaFilters: [String], scrolledToSelectedFilter: Bool, scope: SearchScope) {
        queryMediaFilters = mediaFilters

        isFetchingAnExtraPage = true
        searchRepository.fetchMediaSearchResultPage(for: queryText, mediaFilters: mediaFilters, limit: SearchPresenter.pageSize, requestTimeout: remoteConfigRepository.requestTimeout, after: nil) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success((let page, let filters)):
                if let page = page {
                    let searchResultItems = page.elements.map { SearchResultItem.media($0) }
                    let pageInfo = SearchOverviewResult.PageInfo(endCursor: page.nextPage, hasNextPage: page.hasNextPage)
                    self.searchResult?.setMediaItems(searchResultItems, newPageInfo: pageInfo)
                    self.searchResult?.setMediaFilters(result: filters)
                    let sections = self.sections(for: scope, query: queryText)
                    self.trackSearchResultsShown(query: queryText, mediaFilters: mediaFilters, scope: scope, sections: sections)
                    self.trackSearchFiltersShown(query: queryText, scope: scope)
                    self.view?.showSectionsScrolledToTop(sections, searchTerm: queryText, scope: scope)
                    if scrolledToSelectedFilter {
                        self.view?.scrollToSelectedMediaFilter()
                    }
                }
            case .failure:
                let sections = self.sections(for: scope, query: queryText)
                self.view?.showSections(sections, searchTerm: queryText, scope: scope)
            }

            self.isFetchingAnExtraPage = false
        }
    }
}

private extension SearchPresenter {
    private func trackArticleSelected(articleId: LearningCardIdentifier, referrer: Tracker.Event.Article.Referrer) {
        self.trackingProvider.track(.articleSelected(articleID: articleId.value, referrer: referrer))
    }

    private func trackSearchSessionStartedIfNeeded(with query: String?) {
        guard isSearchSessionActive == false else { return }

        searchSessionId = UUID().uuidString
        isSearchSessionActive = true
        trackingProvider.track(.searchSessionStarted(searchSessionId: searchSessionId, searchSessionQuery: query))
    }

    private func trackSearchQueryCommitted(with query: String?,
                                           fromSource: Tracker.Event.Search.SearchQuerySource,
                                           instantTarget: SearchSuggestionItem? = nil,
                                           searchSuggestionResult: SearchSuggestionResult? = nil) {
        // If the committed search query comes from an offline suggestion ==> The fired tracking event should be an offline one
        var reliesOnOfflineResult: Bool {
            switch searchSuggestionResult?.resultType {
            case .offline: return true
            case nil, .online: return false
            }
        }

        let method: Tracker.Event.Search.SearchQueryInputMethod
        switch dictationObserver.currentInputSource {
        case .keyboard: method = .keyboard
        case .dictation: method = .dictation
        }

        if reliesOnOfflineResult {
            self.trackingProvider.track(.searchOfflineQueryCommitted(fromSource: fromSource,
                                                                     instantTarget: instantTarget,
                                                                     queryValue: query,
                                                                     searchSessionId: searchSessionId,
                                                                     method: method))
        } else {
            self.trackingProvider.track(.searchQueryCommitted(fromSource: fromSource,
                                                              instantTarget: instantTarget,
                                                              queryValue: query,
                                                              searchSessionId: searchSessionId,
                                                              method: method))
        }
        isSearchSessionActive = false
        dictationObserver.reset()
    }

    private func trackSearchInputFieldFocused(with currentValue: String) {
        trackingProvider.track(.searchInputFieldFocused(currentValue: currentValue, searchSessionId: searchSessionId))
    }

    private func trackSearchSuggestionsShown(forInputValue: String, currentInputValue: String, suggestions: [SearchSuggestionItem]) {

        switch searchSuggestionResult?.resultType {
        case .online:
            self.trackingProvider.track(.searchSuggestionsShown(forInputValue: forInputValue, currentInputValue: currentInputValue, searchSessionId: searchSessionId, suggestions: suggestions))
        case .offline:
            self.trackingProvider.track(.searchOfflineSuggestionsShown(searchSessionId: searchSessionId, searchSessionQuery: forInputValue, suggestions: suggestions))
        case .none: break
        }
    }

    private func trackSearchSuggestionsApplied(currentInputValue: String, selectedIndex: Int, fromSuggestions: [SearchSuggestionItem]?) {
        guard let fromSuggestions = fromSuggestions else { return }

        switch searchSuggestionResult?.resultType {
        case .online:
            self.trackingProvider.track(.searchSuggestionApplied(currentInputValue: currentInputValue, fromSuggestions: fromSuggestions, searchSessionId: searchSessionId, selectedIndex: selectedIndex))
        case .offline:
            self.trackingProvider.track(.searchOfflineSuggestionApplied(currentInputValue: currentInputValue, fromSuggestions: fromSuggestions, searchSessionId: searchSessionId, selectedIndex: selectedIndex))
        default: break
        }

    }

    private func trackSearchResultsShown(query: String, mediaFilters: [String], scope: SearchScope?, sections: [SearchResultSection]) {
        let searchResultUuids = searchResultUUIDs(from: scope)
        let searchResultViewName = searchResultViewName(from: scope)

        switch searchResult?.resultType {
        case .online:
            trackingProvider.track(.searchResultsShown(didYouMean: searchResult?.correctedSearchTerm, resultUuids: searchResultUuids, searchSessionId: searchSessionId, searchSessionQuery: query, searchSessionDYM: searchResult?.correctedSearchTerm ?? "", view: Tracker.Event.Search.View(name: searchResultViewName, mediaFilters: mediaFilters)))
        case .offline:
            // TODO: update offline event
            trackingProvider.track(.searchOfflineResultsShown(results: (nil, []), searchSessionId: searchSessionId, searchSessionQuery: query, view: Tracker.Event.Search.View(name: searchResultViewName, mediaFilters: mediaFilters)))
        case .none: break
        }
    }

    private func trackSearchResultsErrorShown(for error: String, query: String, mediaFilters: [String], scope: SearchScope?) {
        let searchResultViewName = searchResultViewName(from: scope)
        trackingProvider.track(.searchResultsErrorShown(error: error, searchSessionId: searchSessionId, searchSessionQuery: query, searchSessionDYM: searchResult?.correctedSearchTerm ?? "", view: Tracker.Event.Search.View(name: searchResultViewName, mediaFilters: mediaFilters)))
    }

    private func trackSearchResultsViewChanged(previousScope: SearchScope, newScope: SearchScope, query: String) {
        let previousSearchResultViewName = searchResultViewName(from: previousScope)
        let newSearchResultViewName = searchResultViewName(from: newScope)

        trackingProvider.track(
            .searchResultsViewChanged(newView: Tracker.Event.Search.View(name: newSearchResultViewName,
                                                                           mediaFilters: queryMediaFilters),
                                      previousView: Tracker.Event.Search.View(name: previousSearchResultViewName,
                                                                                mediaFilters: queryMediaFilters),
                                      searchSessionId: searchSessionId,
                                      searchSessionQuery: query,
                                      searchSessionDYM: searchResult?.correctedSearchTerm ?? ""))
    }

    private func trackSearchResultsMoreRequested(query: String, scope: SearchScope, additionalNumberRequested: Int, currentResultCount: Int) {
        let searchResultViewName = searchResultViewName(from: scope)
        trackingProvider.track(.searchResultsMoreRequested(additionalNumberRequested: additionalNumberRequested, currentResultCount: currentResultCount, searchSessionId: searchSessionId, searchSessionQuery: query, searchSessionDYM: searchResult?.correctedSearchTerm ?? "", view: Tracker.Event.Search.View(name: searchResultViewName, mediaFilters: queryMediaFilters)))
    }

    private func trackSearchResultSelected(query: String, selectedIndex: Int, selectedSubIndex: Int?, targetUuid: String) {
        let searchResultViewName = searchResultViewName(from: lastSelectedSearchScope)
        let searchResultItems = searchResultItems(from: lastSelectedSearchScope)

        switch searchResult?.resultType {
        case .online:
            trackingProvider.track(
                .searchResultSelected(
                    fromView: Tracker.Event.Search.View(name: searchResultViewName,
                                                        mediaFilters: queryMediaFilters),
                    searchSessionId: searchSessionId,
                    searchSessionQuery: query,
                    searchSessionDYM: searchResult?.correctedSearchTerm ?? "",
                    selectedIndex: selectedIndex,
                    selectedSubIndex: selectedSubIndex,
                    targetUuid: targetUuid))
        case .offline:
            trackingProvider.track(
                .searchOfflineResultSelected(
                    fromResults: searchResultItems,
                    fromView: Tracker.Event.Search.View( name: searchResultViewName,
                                                         mediaFilters: queryMediaFilters),
                    searchSessionId: searchSessionId,
                    searchSessionQuery: query,
                    selectedIndex: selectedIndex,
                    selectedSubIndex: selectedSubIndex ?? 0))
        case .none: break
        }
    }

    private func trackDidYouMean(searchTerm: String, didYouMean: String, searchID: String, tapped: Bool) {
        let followupQuery = "\"\(searchTerm)\"" // <- double quotes to prevent further "did you mean" suggestions
        let searchSessionQuery = searchTerm
        let searchSessionDYM = didYouMean

        if tapped {
            trackingProvider.track(.searchFollowupQuerySelected(
                followupQuery: followupQuery,
                searchSessionId: searchSessionId,
                searchSessionQuery: searchSessionQuery,
                searchSessionDYM: searchSessionDYM))
        } else {
            trackingProvider.track(.searchFollowupQueriesShown(
                followupQuery: followupQuery,
                searchSessionId: searchID,
                searchSessionQuery: searchTerm,
                searchSessionDYM: searchSessionDYM))
        }
    }

    private func trackSearchFiltersShown(query: String, scope: SearchScope?) {
        let searchResultViewName = searchResultViewName(from: scope)

        trackingProvider.track(.searchFiltersShown(filtersMedia: searchResult?.searchMediaFiltersResult.filters ?? [], searchSessionId: searchSessionId, searchSessionQuery: query, searchSessionDYM: searchResult?.correctedSearchTerm ?? "", view: Tracker.Event.Search.View(name: searchResultViewName, mediaFilters: queryMediaFilters)))
    }

    private func searchResultViewName(from scope: SearchScope?) -> Tracker.Event.Search.View.SearchResultsViewName {
        switch scope {
        case .overview, .none:
            return .overview
        case .library:
            return .articles
        case .pharma:
            return .pharma
        case .guideline:
            return .guidelines
        case .media:
            return .media
        }
    }

    private func searchResultItems(from scope: SearchScope?) -> (PhrasionaryItem?, [SearchResultItem]) {
        guard let searchResult = self.searchResult else { return (nil, []) }
        switch scope {
        case .overview, nil:
            var searchResultItems: [SearchResultItem] = []
            searchResultItems.append(contentsOf: searchResult.searchArticleResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTab))
            searchResultItems.append(contentsOf: searchResult.searchPharmaResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTab))
            searchResultItems.append(contentsOf: searchResult.searchMediaResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTabForMedia))
            searchResultItems.append(contentsOf: searchResult.searchGuidelineResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTab))
            return (searchResult.phrasionary, searchResultItems)
        case .library:
            return (nil, searchResult.searchArticleResultItems)
        case .pharma:
            return (nil, searchResult.searchPharmaResultItems)
        case .guideline:
            return (nil, searchResult.searchGuidelineResultItems)
        case .media:
            return (nil, searchResult.searchMediaResultItems)
        }
    }

    private func searchResultUUIDs(from scope: SearchScope?) -> [String] {
        guard let searchResult = self.searchResult else { return [] }
        switch scope {
        case .overview, nil:
            var searchResultItems: [String] = []
            if let phrasionary = searchResult.phrasionary {
                searchResultItems.append(phrasionary.resultUUID)
            }
            searchResultItems.append(contentsOf: searchResult.searchArticleResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTab).map { $0.resultUUID })
            searchResultItems.append(contentsOf: searchResult.searchPharmaResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTab).map { $0.resultUUID })
            searchResultItems.append(contentsOf: searchResult.searchMediaResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTabForMedia).map { $0.resultUUID })
            searchResultItems.append(contentsOf: searchResult.searchGuidelineResultItems.prefix(SearchPresenter.numberOfSectionResultsInOverviewTab).map { $0.resultUUID })
            return searchResultItems
        case .library:
            return searchResult.searchArticleResultItems.map { $0.resultUUID }
        case .pharma:
            return searchResult.searchPharmaResultItems.map { $0.resultUUID }
        case .guideline:
            return searchResult.searchGuidelineResultItems.map { $0.resultUUID }
        case .media:
            return searchResult.searchMediaResultItems.map { $0.resultUUID }
        }
    }
}
