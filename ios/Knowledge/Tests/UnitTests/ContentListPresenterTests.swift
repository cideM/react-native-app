//
//  ContentListPresenterTests.swift
//  KnowledgeTests
//
//  Created by Manaf Alabd Alrahim on 20.04.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import Networking
import StoreKit
import XCTest

class ContentListPresenterTests: XCTestCase {

    var contentListPresenter: ContentListPresenterType!
    var dashboardCoordinator: DashboardCoordinatorTypeMock!
    var searchRepository: SearchRepositoryTypeMock!
    var userDataRepository: UserDataRepositoryTypeMock!
    var pharmaRepository: PharmaRepositoryTypeMock!
    var mediaRepository: MediaRepositoryTypeMock!
    var remoteConfigRepository: RemoteConfigRepositoryTypeMock!
    var userDataClient: UserDataClientMock!
    var appConfiguration: ConfigurationMock!

    override func setUp() {
        dashboardCoordinator = DashboardCoordinatorTypeMock()
        searchRepository = SearchRepositoryTypeMock()
        userDataRepository = UserDataRepositoryTypeMock()
        pharmaRepository = PharmaRepositoryTypeMock()
        mediaRepository = MediaRepositoryTypeMock()
        remoteConfigRepository = RemoteConfigRepositoryTypeMock()
        userDataClient = UserDataClientMock()
        appConfiguration = ConfigurationMock(appVariant: .wissen)

    }

    private func presenterWith(clinicalTool: ClinicalTool) {
        contentListPresenter = ContentListPresenter(clinicalTool: clinicalTool,
                                                    coordinator: dashboardCoordinator,
                                                    searchRepository: searchRepository,
                                                    userDataRepository: userDataRepository,
                                                    pharmaRepository: pharmaRepository,
                                                    mediaRepository: mediaRepository,
                                                    remoteConfigRepository: remoteConfigRepository,
                                                    userDataClient: userDataClient,
                                                    appConfiguration: appConfiguration)
    }

    func testThatContentListIsInitiallyLoadedWithEmptyQueryForPharma() {
        let view = ContentListViewTypeMock()

        let pharmaItems = [PharmaSearchItem.fixture(), PharmaSearchItem.fixture()]
        searchRepository.fetchPharmaSearchResultPageHandler = { _, _, _, _, completion in
            let page: Page<PharmaSearchItem> = .init(elements: pharmaItems,
                                                     nextPage: "",
                                                     hasNextPage: false)
            completion(.success(page))
        }
        self.presenterWith(clinicalTool: .drugDatabase)

        let loadingExpectation = expectation(description: "view is loading")
        let loadedExpectation = expectation(description: "view is loaded")
        view.setViewStateHandler = { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .loaded(let viewData, _):
                XCTAssertEqual(viewData.items.count, pharmaItems.count)
                for item in viewData.items {
                    switch item {
                    case .pharma:
                        continue
                    default:
                        XCTFail("unexpected content type \(item)")
                    }
                }
                loadedExpectation.fulfill()
            default:
                XCTFail("unexpected state \(state)")
            }
        }

        contentListPresenter.view = view
        waitForExpectations(timeout: 0.1)
    }

    func testThatContentListIsInitiallyLoadedWithEmptyQueryForMonographs() {
        let view = ContentListViewTypeMock()

        let monographItems = [MonographSearchItem.fixture(), MonographSearchItem.fixture()]
        searchRepository.fetchMonographSearchResultPageHandler = { _, _, _, _, completion in
            let page: Page<MonographSearchItem> = .init(elements: monographItems,
                                                     nextPage: "",
                                                     hasNextPage: false)
            completion(.success(page))
        }

        appConfiguration.appVariant = .knowledge
        self.presenterWith(clinicalTool: .drugDatabase)

        let loadingExpectation = expectation(description: "view is loading")
        let loadedExpectation = expectation(description: "view is loaded")
        view.setViewStateHandler = { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .loaded(let viewData, _):
                XCTAssertEqual(viewData.items.count, monographItems.count)
                for item in viewData.items {
                    switch item {
                    case .monograph:
                        continue
                    default:
                        XCTFail("unexpected content type \(item)")
                    }
                }
                loadedExpectation.fulfill()
            default:
                XCTFail("unexpected state \(state)")
            }
        }

        contentListPresenter.view = view
        waitForExpectations(timeout: 0.1)
    }

    func testThatContentListIsInitiallyLoadedWithEmptyQueryForGuidelines() {
        let view = ContentListViewTypeMock()

        let guiedlineItems = [GuidelineSearchItem.fixture(), GuidelineSearchItem.fixture()]
        searchRepository.fetchGuidelineSearchResultPageHandler = { _, _, _, _, completion in
            let page: Page<GuidelineSearchItem> = .init(elements: guiedlineItems,
                                                     nextPage: "",
                                                     hasNextPage: false)
            completion(.success(page))
        }
        self.presenterWith(clinicalTool: .guidelines)

        let loadingExpectation = expectation(description: "view is loading")
        let loadedExpectation = expectation(description: "view is loaded")
        view.setViewStateHandler = { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .loaded(let viewData, _):
                XCTAssertEqual(viewData.items.count, guiedlineItems.count)
                for item in viewData.items {
                    switch item {
                    case .guideline:
                        continue
                    default:
                        XCTFail("unexpected content type \(item)")
                    }
                }
                loadedExpectation.fulfill()
            default:
                XCTFail("unexpected state \(state)")
            }
        }

        contentListPresenter.view = view
        waitForExpectations(timeout: 0.1)
    }

    func testThatContentListIsInitiallyLoadedWithEmptyQueryForMedia() {
        let view = ContentListViewTypeMock()

        let mediaItems = [MediaSearchItem.fixture(), MediaSearchItem.fixture()]
        searchRepository.fetchMediaSearchResultPageHandler = { _, _, _, _, _, completion in
            let page: Page<MediaSearchItem> = .init(elements: mediaItems,
                                                     nextPage: "",
                                                     hasNextPage: false)
            completion(.success((page, .fixture())))
        }
        let clinicalTool = [ClinicalTool.flowcharts, ClinicalTool.calculators].randomElement()!
        self.presenterWith(clinicalTool: clinicalTool)

        let loadingExpectation = expectation(description: "view is loading")
        let loadedExpectation = expectation(description: "view is loaded")
        view.setViewStateHandler = { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .loaded(let viewData, _):
                XCTAssertEqual(viewData.items.count, mediaItems.count)
                for item in viewData.items {
                    switch item {
                    case .media:
                        continue
                    default:
                        XCTFail("unexpected content type \(item)")
                    }
                }
                loadedExpectation.fulfill()
            default:
                XCTFail("unexpected state \(state)")
            }
        }

        contentListPresenter.view = view
        waitForExpectations(timeout: 0.1)
    }

    func testThatViewShowsErrorWithActionWhenOffline() {
        let view = ContentListViewTypeMock()
        let clinicalTool = ClinicalTool.calculators

        searchRepository.fetchMediaSearchResultPageHandler = { _, _, _, _, _, completion in
            completion(.failure(.networkError(NetworkError<EmptyAPIError>.requestTimedOut )))
        }
        searchRepository.fetchGuidelineSearchResultPageHandler = { _, _, _, _, completion in
            completion(.failure(.networkError(NetworkError<EmptyAPIError>.requestTimedOut )))
        }
        searchRepository.fetchMonographSearchResultPageHandler = { _, _, _, _, completion in
            completion(.failure(.networkError(NetworkError<EmptyAPIError>.requestTimedOut )))
        }
        searchRepository.fetchPharmaSearchResultPageHandler = { _, _, _, _, completion in
            completion(.failure(.networkError(NetworkError<EmptyAPIError>.requestTimedOut )))
        }
        searchRepository.fetchPharmaSearchResultOfflineHandler = { _, completion in
            completion(nil)
        }

        self.presenterWith(clinicalTool: clinicalTool)

        let loadingExpectation = expectation(description: "view is loading")
        let errorExpectation = expectation(description: "view is loaded with error")
        view.setViewStateHandler = { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .error(_, _, let actionTitle):
                XCTAssertNotNil(actionTitle)
                errorExpectation.fulfill()
            case .empty:
                XCTFail("unexpected state \(state)")
            default: ()
            }
        }

        contentListPresenter.view = view
        waitForExpectations(timeout: 0.1)
    }

    func testThatViewShowsMessageWhenListIsEmpty() {
        let view = ContentListViewTypeMock()
        let clinicalTool = ClinicalTool.calculators

        searchRepository.fetchPharmaSearchResultPageHandler = { _, _, _, _, completion in
            completion(.success(.init(elements: [], nextPage: "", hasNextPage: false)))
        }
        searchRepository.fetchMonographSearchResultPageHandler = { _, _, _, _, completion in
            completion(.success(.init(elements: [], nextPage: "", hasNextPage: false)))
        }
        searchRepository.fetchGuidelineSearchResultPageHandler = { _, _, _, _, completion in
            completion(.success(.init(elements: [], nextPage: "", hasNextPage: false)))
        }
        searchRepository.fetchMediaSearchResultPageHandler = { _, _, _, _, _, completion in
            completion(.success((.init(elements: [], nextPage: "", hasNextPage: false),
                                 MediaFiltersResult.fixture())))
        }

        self.presenterWith(clinicalTool: clinicalTool)

        let loadingExpectation = expectation(description: "view is loading")
        let emptyExpectation = expectation(description: "view is loaded with error")
        view.setViewStateHandler = { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .empty:
                emptyExpectation.fulfill()
            case .error:
                XCTFail("unexpected state \(state)")
            default: ()
            }
        }

        contentListPresenter.view = view
        waitForExpectations(timeout: 0.1)
    }
}
