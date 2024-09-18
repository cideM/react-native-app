//
//  InAppPurchaseApplicationServiceTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 08.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
@testable import Knowledge_DE
import XCTest

import Foundation
import Domain
import Networking
import StoreKit

class InAppPurchaseApplicationServiceTests: XCTestCase {

    var iAPApplicationService: InAppPurchaseApplicationServiceType!
    var accessClient: MembershipAccessClientMock!
    var iAPSubscriptionClient: InAppPurchaseSubscriptionClientMock!

    override func setUp() {
        accessClient = MembershipAccessClientMock()
        iAPSubscriptionClient = InAppPurchaseSubscriptionClientMock()

        iAPApplicationService = InAppPurchaseApplicationService(inAppPurchaseClient: accessClient, subscriptionClient: iAPSubscriptionClient, analyticsTracking: TrackingTypeMock())
    }

    func testBuyAndLinkShouldNotCallTheClientIfThePurchaseWasNotSuccessful() {
        iAPSubscriptionClient.purchaseProductHandler = { completion in
            completion(.failure(.internalError("")))
        }

        let expectation = self.expectation(description: "iAPApplicationService buyAndLink was called")

        iAPApplicationService.buyAndLink { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(accessClient.uploadInAppPurchaseSubscriptionReceiptCallCount, 0, "The client.linkInAppPurchaseCallCount was called even if the purchase wasn't successful.")
    }

    func testBuyAndLinkShouldCallTheClientAndFinishTransactionIfThePurchaseWasSuccessful() {
        let expectedTransaction = SKPaymentTransaction()
        iAPSubscriptionClient.localReceiptData = Data()

        accessClient.uploadInAppPurchaseSubscriptionReceiptHandler = { _, _, completion in
            completion(.success(()))
        }

        iAPSubscriptionClient.purchaseProductHandler = { completion in
            completion(.success(expectedTransaction))
        }

        let iAPSubscriptionClientFinishTransactionExpectation = self.expectation(description: "iAPSubscriptionClient Finish transaction is called")

        iAPSubscriptionClient.finishTransactionHandler = { transaction in
            XCTAssertEqual(transaction, expectedTransaction)
            iAPSubscriptionClientFinishTransactionExpectation.fulfill()
        }

        let buyAndLinkExpectation = self.expectation(description: "buyAndLinkExpectation Finished")
        iAPApplicationService.buyAndLink { _ in
            XCTAssertEqual(self.accessClient.uploadInAppPurchaseSubscriptionReceiptCallCount, 1)
            buyAndLinkExpectation.fulfill()
        }

        wait(for: [iAPSubscriptionClientFinishTransactionExpectation, buyAndLinkExpectation], timeout: 1)
    }

    func testBuyAndLinkShouldSetTheStateToUnlinkedIfLinkingFails() {

        let expectedTransaction = SKPaymentTransaction()
        iAPSubscriptionClient.localReceiptData = Data()

        iAPSubscriptionClient.purchaseProductHandler = { completion in
            completion(.success(expectedTransaction))
        }

        accessClient.uploadInAppPurchaseSubscriptionReceiptHandler = { _, _, completion in
            completion(.failure(.failed(code: .fixture())))
        }

        let expectation = self.expectation(description: "iAPApplicationService buyAndLink is called")

        iAPApplicationService.buyAndLink { _ in
            XCTAssertEqual(self.iAPApplicationService.storeState, .unlinkedInAppPurchaseSubscription)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testBuyAndLinkShouldSetTheStateToActiveOnceFinished() {

        let expectedTransaction = SKPaymentTransaction()
        iAPSubscriptionClient.localReceiptData = Data()

        iAPSubscriptionClient.purchaseProductHandler = { completion in
            completion(.success(expectedTransaction))
        }

        accessClient.uploadInAppPurchaseSubscriptionReceiptHandler = { _, _, completion in
            completion(.success(()))
        }

        let expectation = self.expectation(description: "iAPApplicationService.buyAndLink is called")

        iAPApplicationService.buyAndLink { _ in
            XCTAssertEqual(self.iAPApplicationService.storeState, .activeInAppPurchaseSubscription)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testThatBuyAndLinkCallsFinishTransactionAfterSuccessfullyLinking() {
        let expectedTransaction = SKPaymentTransaction()

        iAPSubscriptionClient.localReceiptData = Data()

        iAPSubscriptionClient.purchaseProductHandler = { completion in
            completion(.success(expectedTransaction))
        }

        accessClient.uploadInAppPurchaseSubscriptionReceiptHandler = { _, _, completion in
            completion(.success(()))
        }

        let expectation = self.expectation(description: "iAPSubscriptionClient finishTransaction was called")

        iAPSubscriptionClient.finishTransactionHandler = { transaction in
            XCTAssertEqual(transaction, expectedTransaction)
            expectation.fulfill()
        }

        iAPApplicationService.buyAndLink { _ in }

        wait(for: [expectation], timeout: 1)
    }

    func testThatRestoreAndLinkCallsFinishTransactionAfterSuccessfullyLinking() {
        let expectedTransaction = SKPaymentTransaction()

        iAPSubscriptionClient.localReceiptData = Data()

        iAPSubscriptionClient.restorePurchasesHandler = { completion in
            completion(.success(expectedTransaction))
        }

        accessClient.uploadInAppPurchaseSubscriptionReceiptHandler = { _, _, completion in
            completion(.success(()))
        }

        let expectation = self.expectation(description: "iAPSubscriptionClient finishTransaction was called")

        iAPSubscriptionClient.finishTransactionHandler = { transaction in
            XCTAssertEqual(transaction, expectedTransaction)
            expectation.fulfill()
        }

        iAPApplicationService.restoreAndLink { _ in }

        wait(for: [expectation], timeout: 1)
    }

    func testRestoreAndLinkShouldSetTheStateToUnlinkedIfLinkingFails() {
        let expectedTransaction = SKPaymentTransaction()

        iAPSubscriptionClient.localReceiptData = Data()

        iAPSubscriptionClient.restorePurchasesHandler = { completion in
            completion(.success(expectedTransaction))
        }

        accessClient.uploadInAppPurchaseSubscriptionReceiptHandler = { _, _, completion in
            completion(.failure(.failed(code: .fixture())))
        }

        let expectation = self.expectation(description: "iAPApplicationService restoreAndLink is called with result")

        iAPApplicationService.restoreAndLink { _ in
            XCTAssertEqual(self.iAPApplicationService.storeState, .unlinkedInAppPurchaseSubscription)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testRestoreAndLinkShouldCallFinishTransactionOnceFinished() {
        let expectedTransaction = SKPaymentTransaction()

        iAPSubscriptionClient.localReceiptData = Data()

        iAPSubscriptionClient.restorePurchasesHandler = { completion in
            completion(.success(expectedTransaction))
        }

        accessClient.uploadInAppPurchaseSubscriptionReceiptHandler = { _, _, completion in
            completion(.success(()))
        }

        let expectation = self.expectation(description: "iAPApplicationService restoreAndLink was called with result")

        iAPApplicationService.restoreAndLink { _ in
            XCTAssertEqual(self.iAPSubscriptionClient.finishTransactionCallCount, 1)
            XCTAssertEqual(self.iAPApplicationService.storeState, .activeInAppPurchaseSubscription)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testLinkShouldFailIfTheReceiptDataWasntFound() {
        let expectedTransaction = SKPaymentTransaction()

        iAPSubscriptionClient.restorePurchasesHandler = { completion in
            completion(.success(expectedTransaction))
        }

        let expectation = self.expectation(description: "iAPApplicationService restoreAndLink was called with result")

        iAPApplicationService.link { result in
            if case .success = result {
                XCTFail("Linking should fail without receipt data.")
            }
            XCTAssertEqual(self.accessClient.uploadInAppPurchaseSubscriptionReceiptCallCount, 0)
            expectation.fulfill()
        }

         wait(for: [expectation], timeout: 1)
    }

    func testThatPurchaseInfoReturnsExpectedValues() {

        let subscriptionState = InAppPurchaseSubscriptionState.subscribed
        iAPSubscriptionClient.fetchSubscriptionStateHandler = { callback in
            callback(.success(subscriptionState))
        }

        let canPurchaseInAppSubscription = Bool.fixture()
        let hasActiveInAppSubscription = Bool.fixture()
        accessClient.getAmbossSubscriptionStateHandler = { callback in
            let state = AmbossSubscriptionState(canPurchaseInAppSubscription: canPurchaseInAppSubscription,
                                                     hasActiveInAppSubscription: hasActiveInAppSubscription)
            callback(.success(state))
        }

        iAPSubscriptionClient.updateProductMetadataHandler = { calllback in
            // An empty SKProduct is enough to make "hasProductMetadata" turn "true"
            calllback(.success(SKProductMock()))
        }

        iAPApplicationService.updateStoreState()

        let purchaseInfo = iAPApplicationService.purchaseInfo()
        print(purchaseInfo)
        XCTAssertEqual(purchaseInfo.canPurchase, canPurchaseInAppSubscription)
        XCTAssertEqual(purchaseInfo.hasActiveIAPSubscription, hasActiveInAppSubscription)
        XCTAssertEqual(purchaseInfo.subscriptionState, subscriptionState)
        XCTAssertTrue(purchaseInfo.hasProductMetadata)
    }
}
