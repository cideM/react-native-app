//
//  DashboardPresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 23.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import StoreKit
import XCTest

class DashboardPresenterTests: XCTestCase {
    var dashboardCoordinator: DashboardCoordinatorTypeMock!
    var trackingProvider: TrackingTypeMock!
    var dashboardPresenter: DashboardPresenterType!
    var appConfiguration: ConfigurationMock!
    var storage: Storage!
    var remoteConfigRepository: RemoteConfigRepositoryTypeMock!
    var consentApplicationService: ConsentApplicationServiceType!
    var inAppPurchaseApplicationService: InAppPurchaseApplicationServiceTypeMock!
    var brazeClient: BrazeApplicationServiceTypeMock!
    var authorizationRepository: AuthorizationRepositoryTypeMock!

    override func setUp() {
        dashboardCoordinator = DashboardCoordinatorTypeMock()
        trackingProvider = TrackingTypeMock()
        appConfiguration = ConfigurationMock(appVariant: .wissen)
        storage = MemoryStorage()
        remoteConfigRepository = RemoteConfigRepositoryTypeMock()
        consentApplicationService = ConsentApplicationServiceTypeMock()
        brazeClient = BrazeApplicationServiceTypeMock()
        authorizationRepository = AuthorizationRepositoryTypeMock()

        inAppPurchaseApplicationService = InAppPurchaseApplicationServiceTypeMock()
        inAppPurchaseApplicationService.purchaseInfoHandler = { InAppPurchaseInfo.fixture() }

        dashboardPresenter = DashboardPresenter(coordinator: dashboardCoordinator,
                                                trackingProvider: trackingProvider,
                                                appConfiguration: appConfiguration,
                                                tagRepository: TagRepositoryTypeMock(),
                                                maxNumberOfRecents: 5,
                                                storage: storage,
                                                remoteConfigRepository: remoteConfigRepository,
                                                consentApplicationService: consentApplicationService,
                                                inAppPurchaseApplicationService: inAppPurchaseApplicationService,
                                                userDataRepository: UserDataRepositoryTypeMock(),
                                                listTrackingProvider: ListTrackingProviderMock(),
                                                brazeClient: brazeClient,
                                                authorizationRepository: authorizationRepository)
    }

    func testThatTheCoordinatorIsAskedToNavigateToSearchWhenSearchIsTapped() {
        XCTAssertEqual(dashboardCoordinator.navigateCallCount, 0)

        dashboardPresenter.didTapSearch()

        XCTAssertEqual(dashboardCoordinator.navigateCallCount, 1)
    }

    func testThatTheCoordinatorIsAskedToNavigateToTheCompleteRecentsListWhenAllButtonIsTapped() {
        XCTAssertEqual(dashboardCoordinator.navigateToCompleteRecentsListCallCount, 0)

        dashboardPresenter.didTapAllRecentsButton()

        XCTAssertEqual(dashboardCoordinator.navigateToCompleteRecentsListCallCount, 1)
    }

    func testThatDashboardDiscoveryCardsDisplayedEventIsNotSentWhenTheCardsAreNotDisplayed() {
        let expectation = expectation(description: "Tracker was not called")
        expectation.isInverted = true
        trackingProvider.trackHandler = { event in
            switch event {
            case .dashboard(let dashboardEvent):
                switch dashboardEvent {
                case .dashboardDiscoveryCardsDisplayed: expectation.fulfill()
                default: break
                }
            default: break
            }
        }

        let view = DashboardViewTypeMock()
        dashboardPresenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatIAPBannerIsShownIfUserHasTrialAccessAndCanPurchaseIAPSubscription() {
        inAppPurchaseApplicationService.purchaseInfoHandler = {
            InAppPurchaseInfo.fixture(canPurchase: true, hasActiveIAPSubcription: false, hasTrialAccess: true)
        }

        let view = DashboardViewTypeMock()
        view.updateIAPBannerHandler = { _, _, isHidden in
            XCTAssertFalse(isHidden)
        }

        dashboardPresenter.view = view

        XCTAssertEqual(view.updateIAPBannerCallCount, 1)
    }

    func testThatIAPBannerIsntShownIfUserDoesntHaveTrialAccess() {
        inAppPurchaseApplicationService.purchaseInfoHandler = {
            InAppPurchaseInfo.fixture(canPurchase: true, hasActiveIAPSubcription: false, hasTrialAccess: false)
        }

        let view = DashboardViewTypeMock()
        view.updateIAPBannerHandler = { _, _, isHidden in
            XCTAssertTrue(isHidden)
        }

        dashboardPresenter.view = view

        XCTAssertEqual(view.updateIAPBannerCallCount, 1)
    }

    func testThatIAPBannerIsntShownIfUserCantPurchase() {
        inAppPurchaseApplicationService.purchaseInfoHandler = {
            InAppPurchaseInfo.fixture(canPurchase: false, hasActiveIAPSubcription: false, hasTrialAccess: true)
        }

        let view = DashboardViewTypeMock()
        view.updateIAPBannerHandler = { _, _, isHidden in
            XCTAssertTrue(isHidden)
        }

        dashboardPresenter.view = view

        XCTAssertEqual(view.updateIAPBannerCallCount, 1)
    }

    func testThatIAPBannerIsntShownIfUserAlreadyHasASubscription() {
        inAppPurchaseApplicationService.purchaseInfoHandler = {
            InAppPurchaseInfo.fixture(canPurchase: true, hasActiveIAPSubcription: true, hasTrialAccess: false)
        }

        let view = DashboardViewTypeMock()
        view.updateIAPBannerHandler = { _, _, isHidden in
            XCTAssertTrue(isHidden)
        }

        dashboardPresenter.view = view

        XCTAssertEqual(view.updateIAPBannerCallCount, 1)
    }

    func testThatTheCoordinatorIsAskedToGoToStoreWhenIAPBannerTapped() {
        XCTAssertEqual(dashboardCoordinator.navigateToStoreCallCount, 0)

        dashboardPresenter.didTapIAPBanner()

        XCTAssertEqual(dashboardCoordinator.navigateToStoreCallCount, 1)
    }
}
