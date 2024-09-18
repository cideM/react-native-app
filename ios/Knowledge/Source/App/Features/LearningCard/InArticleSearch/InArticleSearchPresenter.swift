//
//  InArticleSearchPresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 17.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

protocol InArticleSearchPresenterType: AnyObject {
    var view: InArticleSearchViewType? { get set }
    func searchTextDidChange(_ newSearchText: String)
    func goToNextSearchResult()
    func goToPreviousSearchResult()
    func cancelSearch()
}

final class InArticleSearchPresenter: InArticleSearchPresenterType {

    weak var view: InArticleSearchViewType?
    private let learningCardTracker: LearningCardTrackerType
    private let tracker: TrackingType

    private var searchRepository: InArticleSearchRepositoryType? {
        didSet {
            if let searchRepository = searchRepository {
                view?.setSearchLabelText(searchRepository.countText)
            } else {
                view?.setSearchLabelText("0/0")
            }
        }
    }

    init(learningCardTracker: LearningCardTrackerType) {
        self.learningCardTracker = learningCardTracker
        self.tracker = learningCardTracker.trackingProvider
    }

    func searchTextDidChange(_ newSearchText: String) {
        // The "startSearch" call below might not come back quickly enough
        // and hence "swallow" character count changes,
        // hence this is a seperate step ...
        if newSearchText.count <= 1 {
            // New id every time the user clears the search field
            // Selecting everything and start typing leads to count == 1
            // Thats why the above does not check count == 0
            learningCardTracker.renewFindInPageSessionID()
        }

        view?.startSearch(for: newSearchText) { [weak self] result in
            switch result {
            case .success(let inArticleSearchResponse):
                if let inArticleSearchResponse = inArticleSearchResponse {
                    // searchRepository will be nil if no results hence falling back to 0/0 below ...
                    self?.searchRepository = InArticleSearchRepository(currentResponse: inArticleSearchResponse)
                    self?.learningCardTracker.trackArticleFindInPageEdited(
                        currentInput: newSearchText,
                        totalMatches: self?.searchRepository?.resultCount ?? 0,
                        currentMatch: self?.searchRepository?.currentResultIndex ?? 0)
                }
            case .failure: break
            }
        }
    }

    func goToNextSearchResult() {
        guard let repository = searchRepository else { return }

        repository.currentResultIndex += 1

        view?.goToQueryResultItem(withId: repository.currentSearchResult)
        view?.setSearchLabelText(repository.countText)

        if let searchRepository = searchRepository {
            learningCardTracker.trackArticleFindInPageEdited(
                currentInput: view?.searchText,
                totalMatches: searchRepository.resultCount,
                currentMatch: searchRepository.currentResultIndex)
        }
    }

    func goToPreviousSearchResult() {
        guard let repository = searchRepository else { return }

        repository.currentResultIndex -= 1

        view?.goToQueryResultItem(withId: repository.currentSearchResult)
        view?.setSearchLabelText(repository.countText)

        if let searchRepository = searchRepository {
            learningCardTracker.trackArticleFindInPageEdited(
                currentInput: view?.searchText,
                totalMatches: searchRepository.resultCount,
                currentMatch: searchRepository.currentResultIndex)
        }
    }

    func cancelSearch() {
        view?.stopSearch(with: searchRepository?.currentResponseIdentifier)
        searchRepository = nil
    }
}
