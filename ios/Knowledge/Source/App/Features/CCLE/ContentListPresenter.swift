//
//  ContentListPresenter.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 29.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

/// @mockable
protocol ContentListPresenterType: AnyObject {
    var view: ContentListViewType? { get set }
    var paginationThreshold: Int { get set }

    func searchBarTapped()
    func searchBarTextFieldCanBeginEditting() -> Bool
    func searchBarTextFieldDidBeginEditing()
    func searchBarTextFieldDidEndEditing()
    func searchButtonTapped(query: String)
    func searchBarCancelButtonTapped()
    func retryButtonTapped()
    func didScrollToBottom()
    func didSelect(item: ContentListItemViewData)
}

final class ContentListPresenter: ContentListPresenterType {

    private static let pageSize = 20

    private let clinicalTool: ClinicalTool
    private let coordinator: DashboardCoordinatorType
    private let searchRepository: SearchRepositoryType
    private let userDataRepository: UserDataRepositoryType
    private var pharmaRepository: PharmaRepositoryType
    private let mediaRepository: MediaRepositoryType
    private let remoteConfigRepository: RemoteConfigRepositoryType
    private let userDataClient: UserDataClient
    private let trackingProvider: TrackingType
    private let appConfiguration: Configuration
    private let canFilterList = false

    private var isLoading = false
    private var isFetchingMore = false
    private var hasNextPage = true
    private var pageCursor: String?
    private var viewData = ContentListViewData()
    private var query: String = ""

    var paginationThreshold: Int = 5

    weak var view: ContentListViewType? {
        didSet {
            view?.setUp(title: clinicalTool.title, placeholder: clinicalTool.searchPlaceholder)

            loadInitialList()
        }
    }

    init(clinicalTool: ClinicalTool,
         coordinator: DashboardCoordinatorType,
         searchRepository: SearchRepositoryType = resolve(),
         userDataRepository: UserDataRepositoryType = resolve(),
         pharmaRepository: PharmaRepositoryType = resolve(),
         mediaRepository: MediaRepositoryType = resolve(),
         remoteConfigRepository: RemoteConfigRepositoryType = resolve(),
         userDataClient: UserDataClient = resolve(),
         trackingProvider: TrackingType = resolve(),
         appConfiguration: Configuration = AppConfiguration.shared) {
        self.clinicalTool = clinicalTool
        self.coordinator = coordinator
        self.searchRepository = searchRepository
        self.userDataRepository = userDataRepository
        self.pharmaRepository = pharmaRepository
        self.mediaRepository = mediaRepository
        self.remoteConfigRepository = remoteConfigRepository
        self.userDataClient = userDataClient
        self.trackingProvider = trackingProvider
        self.appConfiguration = appConfiguration
    }

    private func loadInitialList() {
        query = ""
        mediaRepository.clearCache()
        isLoading = true
        view?.setViewState(.loading)
        fetchContent()
    }

    private func fetchContent(after endCursor: String? = nil) {
        switch clinicalTool {
        case .drugDatabase: fetchDrugDatabaseContent(after: endCursor)
        case .guidelines: fetchGuidelinesContent(after: endCursor)
        case .flowcharts: fetchMediaContent(filters: clinicalTool.searchFilters, after: endCursor)
        case .calculators: fetchMediaContent(filters: clinicalTool.searchFilters, after: endCursor)
        case .pocketGuides: break
        }
    }

    private func fetchDrugDatabaseContent(after endCursor: String?) {
        switch appConfiguration.appVariant {
        case .wissen: fetchPharmaContent(after: endCursor)
        case .knowledge: fetchMonographContent(after: endCursor)
        }
    }

    private func fetchPharmaContent(after endCursor: String?) {

        // Setting the timeout here to 2 seconds
        // only if the user has the PharmaDB installed.
        // This way we fallback to offline data faster
        // in case it is available.
        var timeout: TimeInterval?
        if searchRepository.hasOfflinePharmaDB() {
            timeout = remoteConfigRepository.requestTimeout
        }

        searchRepository.fetchPharmaSearchResultPage(
            for: query,
            limit: ContentListPresenter.pageSize,
            requestTimeout: timeout,
            after: endCursor) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let page):
                    var items: [ContentListItemViewData] = []

                    if let page = page {
                        self.hasNextPage = page.hasNextPage
                        self.pageCursor = page.nextPage

                        items = page.elements.map {item in
                            ContentListItemViewData.pharma(item: PharmaSearchViewItem(item: item))
                        }
                    }
                    self.setView(with: items)
                case .failure:
                    if self.isLoading {
                        self.searchRepository.fetchPharmaSearchResultOffline(for: self.query) { offlineItems in
                            self.hasNextPage = false
                            self.pageCursor = nil
                            if let offlineItems = offlineItems {
                                let items = offlineItems.map {item in
                                    ContentListItemViewData.pharma(item: PharmaSearchViewItem(item: item))
                                }
                                self.setView(with: items)
                            } else {
                                self.showErrorViewIfNeeded()
                            }
                        }
                    }
                }
                self.isLoading = false
                self.isFetchingMore = false
        }
    }

    private func fetchMonographContent(after endCursor: String?) {
        searchRepository.fetchMonographSearchResultPage(
            for: query,
            limit: ContentListPresenter.pageSize,
            requestTimeout: nil, // default timeout
            after: endCursor) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let page):
                    var items: [ContentListItemViewData] = []

                    if let page = page {
                        self.hasNextPage = page.hasNextPage
                        self.pageCursor = page.nextPage

                        items = page.elements.map {item in
                            let viewItem = MonographSearchViewItem(title: item.title, details: item.details, deeplink: item.deepLink, resultIndex: 0, children: [], targetUuid: item.targetUUID)
                            return ContentListItemViewData.monograph(item: viewItem)
                        }
                    }
                    self.setView(with: items)
                case .failure:
                    self.showErrorViewIfNeeded()
                }
                self.isLoading = false
                self.isFetchingMore = false
        }
    }

    private func fetchGuidelinesContent(after endCursor: String?) {
        searchRepository.fetchGuidelineSearchResultPage(
            for: query,
            limit: ContentListPresenter.pageSize,
            requestTimeout: nil, // default timeout
            after: endCursor) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let page):
                    var items: [ContentListItemViewData] = []

                    if let page = page {
                        self.hasNextPage = page.hasNextPage
                        self.pageCursor = page.nextPage

                        items = page.elements.enumerated().map { index, item in
                            ContentListItemViewData.guideline(item: GuidelineSearchViewItem(item: item, indexInfo: .init(index: index, subIndex: nil)))
                        }
                    }
                    self.setView(with: items)
                case .failure:
                    self.showErrorViewIfNeeded()
                }
                self.isLoading = false
                self.isFetchingMore = false
        }
    }

    private func fetchMediaContent(filters: [String], after endCursor: String?) {
        searchRepository.fetchMediaSearchResultPage(
            for: query,
            mediaFilters: filters,
            limit: ContentListPresenter.pageSize,
            requestTimeout: nil, // default timeout
            after: endCursor) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success((let page, _)):
                    var items: [ContentListItemViewData] = []

                    if let page = page {
                        self.hasNextPage = page.hasNextPage
                        self.pageCursor = page.nextPage

                        items = page.elements.map {item in
                            let itemTapHandler: (MediaSearchViewItem) -> Void = { [unowned self] mediaViewItem in
                                self.didSelect(item: .media(item: mediaViewItem))
                            }

                            let viewItem = MediaSearchViewItem(
                                mediaId: item.mediaId,
                                title: item.title,
                                url: item.url,
                                externalAdditionType: item.externalAddition?.type,
                                category: item.category,
                                typeName: item.typeName,
                                targetUuid: item.targetUUID,
                                tapHandler: itemTapHandler,
                                imageLoader: self.mediaRepository.image)
                            return ContentListItemViewData.media(item: viewItem)

                        }
                    }
                    self.setView(with: items)
                case .failure:
                    self.showErrorViewIfNeeded()
                }
                self.isLoading = false
                self.isFetchingMore = false
        }
    }

    private func setView(with items: [ContentListItemViewData]) {
        if isFetchingMore {
            viewData.append(newItems: items)
        } else { // if isLoading
            viewData.setItems(newItems: items)
        }

        // Scrolls to top only when isLoading = true
        // This means we are making a new search request
        // and not fetching another page => We should scroll to top

        self.view?.setViewState(.loaded(viewData: viewData, scrolledToTop: isLoading))

        if viewData.isEmpty {
            self.view?.setViewState(.empty(
                title: L10n.ContentList.State.Empty.title,
                subtitle: L10n.ContentList.State.Empty.subtitle))
        }
    }

    private func showErrorViewIfNeeded() {
        if isLoading {
            view?.setViewState(.error(
                title: L10n.ContentList.State.Error.title,
                subtitle: L10n.ContentList.State.Error.subtitle,
                actionTitle: L10n.ContentList.State.Error.Button.title))
        }
    }

    func searchBarTextFieldCanBeginEditting() -> Bool {
        canFilterList
    }

    func searchBarTapped() {
        if !canFilterList {
            if let contentType = getCCLEContentType(from: clinicalTool) {
                // No need to set the search scope via the deeplink
                // the backend will set the correct scope.
                let deeplink = UncommitedSearchDeeplink(type: nil,
                                                        initialQuery: clinicalTool.searchQueryPrefix)
                trackingProvider.track(.ccleSearchStarted(contentType: contentType))
                coordinator.navigate(to: Deeplink.uncommitedSearch(deeplink))
            }
        }
    }

    func searchButtonTapped(query: String) {
        self.query = query
        hasNextPage = true
        pageCursor = nil
        isLoading = true
        view?.setViewState(.loading)
        fetchContent()
    }

    func searchBarTextFieldDidBeginEditing() {
        if let contentType = getCCLEContentType(from: clinicalTool) {
            trackingProvider.track(.ccleSearchStarted(contentType: contentType))
            view?.setOverlay(true)
        }
    }

    func searchBarTextFieldDidEndEditing() {
        if !isLoading {
            view?.setOverlay(false)
        }
    }

    func searchBarCancelButtonTapped() {
        if !query.isEmpty {
            loadInitialList()
        }
    }

    func retryButtonTapped() {
        isLoading = true
        view?.setViewState(.loading)
        fetchContent()
    }

    func didScrollToBottom() {
        guard !isFetchingMore, !isLoading, hasNextPage else { return }
        isFetchingMore = true
        fetchContent(after: pageCursor)
    }

    func didSelect(item: ContentListItemViewData) {
        switch item {
        case .pharma(let item):
            pharmaRepository.selectPharmaSearchResult()
            coordinator.navigate(to: .pharmaCard(PharmaCardDeeplink(
                substance: item.substanceID,
                drug: item.drugId,
                document: nil)))

            trackingProvider.track(.ccleAmbossSubstanceClicked(
                substanceId: item.substanceID.value,
                drugId: item.drugId?.value,
                monographId: nil))
        case .monograph(let item):
            coordinator.navigate(to: .monograph(item.deeplink))

            trackingProvider.track(.ccleAmbossSubstanceClicked(
                substanceId: nil,
                drugId: nil,
                monographId: item.monographId.value))
        case .guideline(let item):
            guard let url = item.externalURL else { return }
            coordinator.showUrl(url: url)
            trackingProvider.track(.ccleGuidelineClicked(
                targetUrl: url.absoluteString))
        case .media(let item):
            if let externalAdditionType = item.externalAdditionType,
               externalAdditionType.hasPlaceholderImage {
                coordinator.navigate(to: ExternalAdditionIdentifier(value: item.mediaId))
            } else {
                let imageResourceIdentifier = ImageResourceIdentifier(value: item.mediaId)
                coordinator.navigate(to: imageResourceIdentifier)
            }

            if self.clinicalTool == .flowcharts {
                trackingProvider.track(.ccleFlowchartClicked(
                    mediaXid: item.mediaId))
            } else if self.clinicalTool == .calculators {
                trackingProvider.track(.ccleCalculatorClicked(
                    mediaXid: item.mediaId))
            }

        }
    }

    private func getCCLEContentType(from clinicalTool: ClinicalTool) -> Tracker.Event.Dashboard.CCLEContentType? {
        switch clinicalTool {
        case .drugDatabase:
            switch appConfiguration.appVariant {
            case .knowledge: return .monograph
            case .wissen: return .pharmaCard
            }
        case .flowcharts: return .flowchart
        case .calculators: return .calculator
        case .guidelines: return .guidline
        case .pocketGuides: return nil
        }
    }
}
