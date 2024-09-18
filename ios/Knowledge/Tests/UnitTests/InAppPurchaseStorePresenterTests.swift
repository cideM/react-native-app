//
//  InAppPurchaseStorePresenterTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 08.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
@testable import Knowledge_DE
import StoreKit
import XCTest

import Foundation

class InAppPurchaseStorePresenterTests: XCTestCase {

    var presenter: InAppPurchaseStorePresenterType!
    var iAPApplicationService: InAppPurchaseApplicationServiceTypeMock!
    var coordinator: InAppPurchaseCoordinatorTypeMock!
    var view: InAppPurchaseStoreViewTypeMock!

    override func setUp() {
        coordinator = InAppPurchaseCoordinatorTypeMock()
        view = InAppPurchaseStoreViewTypeMock()
        iAPApplicationService = InAppPurchaseApplicationServiceTypeMock(storeState: .activeExternalSubscription)
        iAPApplicationService.purchaseInfoHandler = { InAppPurchaseInfo.fixture() }
        presenter = InAppPurchaseStorePresenter(inAppPurchaseApplicationService: iAPApplicationService, coordinator: coordinator)
    }

    func testThatWhenViewIsSetThenPresenterCallsTheUpdateStoreStateAndSetsViewState() {

        XCTAssertEqual(view.setLoadingCallCount, 0)

        presenter.view = view

        XCTAssertEqual(1, view.setLoadingCallCount)

        XCTAssertEqual(iAPApplicationService.updateStoreStateCallCount, 1)
    }

    func testThatWhenStartPurchaseWasTappedThenPresenterCallsTheBuyAndLinkPurchase() {
        presenter.view = view

        let expectation = self.expectation(description: "iAPApplicationService buyAndLink was called")

        iAPApplicationService.buyAndLinkHandler = { _ in
            XCTAssertEqual(self.iAPApplicationService.buyAndLinkCallCount, 1)
            expectation.fulfill()
        }

        presenter.startPurchaseWasTapped()

        wait(for: [expectation], timeout: 1)
    }

    func testThatWhenRestorePurchaseWasTappedThenPresenterCallsTheRestoreAndLinkPurchase() {
        presenter.view = view

        let expectation = self.expectation(description: "iAPApplicationService restoreAndLink was called")

        iAPApplicationService.restoreAndLinkHandler = { _ in
            XCTAssertEqual(self.iAPApplicationService.restoreAndLinkCallCount, 1)
            expectation.fulfill()
        }

        presenter.restorePurchaseWasTapped()

        wait(for: [expectation], timeout: 1)
    }

    func testThatWhenLinkPurchaseWasTappedThenPresenterCallsTheLink() {
        presenter.view = view

        let expectation = self.expectation(description: "iAPApplicationService Link was called")

        iAPApplicationService.linkHandler = { _ in
            XCTAssertEqual(self.iAPApplicationService.linkCallCount, 1)
            expectation.fulfill()
        }

        presenter.linkPurchaseWasTapped()

        wait(for: [expectation], timeout: 1)
    }

    func testThatWhenCancelSubscriptionWasTappedThenPresenterCallsTheManageInAppPurchaseSubscription() {
        presenter.view = view

        presenter.cancelSubscriptionWasTapped()

        XCTAssertEqual(self.coordinator.manageInAppPurchaseSubscriptionCallCount, 1)
    }

    func testThatWhenContactSupportWasTappedThenPresenterCallsGoToSupport() {
        presenter.view = view

        presenter.contactSupportWasTapped()

        XCTAssertEqual(self.coordinator.goToSupportCallCount, 1)
    }

    func testThatWhenRetryWasTappedThenPresenterCallsTheUpdateStateStore() {
        presenter.view = view

        let expectation = self.expectation(description: "iAPApplicationService updateStoreState was called")

        iAPApplicationService.updateStoreStateHandler = {
            XCTAssertEqual(self.iAPApplicationService.updateStoreStateCallCount, 2)
            expectation.fulfill()
        }

        presenter.retryWasTapped()

        wait(for: [expectation], timeout: 1)
    }

    func testThatWhenStateDidChangeNotificationIsTriggeredWithPermanentErrorThenViewIsSetWithShowGenericError() {
        iAPApplicationService.storeState = .loading
        presenter.view = view

        let expectedState: InAppPurchaseStoreState = .permanentError

        XCTAssertEqual(view.showGenericErrorCallCount, 0)

        NotificationCenter.default.post(InAppPurchaseStateDidChangeNotification(oldValue: .loading, newValue: expectedState), sender: iAPApplicationService)

        XCTAssertEqual(view.showGenericErrorCallCount, 1)
    }

    func testThatWhenStateDidChangeNotificationIsTriggeredWithTemporaryErrorThenViewIsSetWithShowGenericError() {
        iAPApplicationService.storeState = .loading
        presenter.view = view

        let expectedState: InAppPurchaseStoreState = .temporaryError

        XCTAssertEqual(view.showGenericErrorCallCount, 0)

        NotificationCenter.default.post(InAppPurchaseStateDidChangeNotification(oldValue: .loading, newValue: expectedState), sender: iAPApplicationService)

        XCTAssertEqual(view.showGenericErrorCallCount, 1)
    }

    func testThatWhenStateDidChangeNotificationIsTriggeredThenViewIsSetWithTheCorrectStateForActiveExternalSubscription() {
        iAPApplicationService.storeState = .loading
        presenter.view = view

        let expectedState: InAppPurchaseStoreState = .activeExternalSubscription

        XCTAssertEqual(view.setActiveExternalSubscriptionCallCount, 0)

        NotificationCenter.default.post(InAppPurchaseStateDidChangeNotification(oldValue: .loading, newValue: expectedState), sender: iAPApplicationService)

        XCTAssertEqual(view.setActiveExternalSubscriptionCallCount, 1)
    }

    func testThatWhenStateDidChangeNotificationIsTriggeredThenViewIsSetWithTheCorrectStateForReadyToBuy() {
        iAPApplicationService.storeState = .loading
        presenter.view = view

        let skProduct = SKProduct()
        skProduct.setValuesForKeys(["productIdentifier": String.fixture(), "price": 10, "priceLocale": NSLocale.current])

        let expectedState: InAppPurchaseStoreState = .readyToBuy(skProduct)

        XCTAssertEqual(view.setReadyToBuyCallCount, 0)

        NotificationCenter.default.post(InAppPurchaseStateDidChangeNotification(oldValue: .loading, newValue: expectedState), sender: iAPApplicationService)

        XCTAssertEqual(view.setReadyToBuyCallCount, 1)
    }

    func testThatWhenStateDidChangeNotificationIsTriggeredThenViewIsSetWithTheCorrectStateForUnlinkedInAppPurchaseSubscription() {
        iAPApplicationService.storeState = .loading
        presenter.view = view

        let expectedState: InAppPurchaseStoreState = .unlinkedInAppPurchaseSubscription
        XCTAssertEqual(view.setUnlinkedInAppPurchaseSubscriptionCallCount, 0)

        NotificationCenter.default.post(InAppPurchaseStateDidChangeNotification(oldValue: .loading, newValue: expectedState), sender: iAPApplicationService)

        XCTAssertEqual(view.setUnlinkedInAppPurchaseSubscriptionCallCount, 1)
    }

    func testThatWhenStateDidChangeNotificationIsTriggeredThenViewIsSetWithTheCorrectStateForActiveInAppPurchaseSubscription() {
        iAPApplicationService.storeState = .loading
        presenter.view = view

        let expectedState: InAppPurchaseStoreState = .activeInAppPurchaseSubscription
        XCTAssertEqual(view.setActiveInAppPurchaseSubscriptionCallCount, 0)

        NotificationCenter.default.post(InAppPurchaseStateDidChangeNotification(oldValue: .loading, newValue: expectedState), sender: iAPApplicationService)

        XCTAssertEqual(view.setActiveInAppPurchaseSubscriptionCallCount, 1)
    }

    func testThatWhenBuyAndLinkFailsThenPresenterSetsTheViewWithError() {
        presenter.view = view

        iAPApplicationService.buyAndLinkHandler = { completion in
            completion(.failure(.internalError("internal error")))
        }

        let expectation = self.expectation(description: "view setError was called")

        view.presentErrorHandler = { _, _ in
            XCTAssertEqual(self.view.presentErrorCallCount, 1)
            expectation.fulfill()
        }

        presenter.startPurchaseWasTapped()

        wait(for: [expectation], timeout: 1)
    }

    func testThatWhenRestoreAndLinkFailsThenPresenterSetsTheViewWithError() {
        presenter.view = view

        iAPApplicationService.restoreAndLinkHandler = { completion in
            completion(.failure(.internalError("internal error")))
        }

        let expectation = self.expectation(description: "view setError was called")

        view.presentErrorHandler = { _, _ in
            XCTAssertEqual(self.view.presentErrorCallCount, 1)
            expectation.fulfill()
        }

        presenter.restorePurchaseWasTapped()

        wait(for: [expectation], timeout: 1)
    }

    func testThatWhenLinkingPurchaseFailsThenPresenterSetsTheViewWithError() {
        presenter.view = view

        iAPApplicationService.linkHandler = { completion in
            completion(.failure(.internalError("internal error")))
        }

        let expectation = self.expectation(description: "view setError was called")

        view.presentErrorHandler = { _, _ in
            XCTAssertEqual(self.view.presentErrorCallCount, 1)
            expectation.fulfill()
        }

        presenter.linkPurchaseWasTapped()

        wait(for: [expectation], timeout: 1)
    }
}
