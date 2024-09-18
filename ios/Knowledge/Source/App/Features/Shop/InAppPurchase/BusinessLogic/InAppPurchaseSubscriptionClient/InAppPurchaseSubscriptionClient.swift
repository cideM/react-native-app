//
//  InAppPurchaser.swift
//  AMBOSS Bibliothek
//
//  Created by CSH on 19.07.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import StoreKit

// sourcery: fixture:
enum InAppPurchaseSubscriptionState {
    case unknown
    case subscribed
    case unsubscribed
}

// Notes: I'm not sure if we need to check if the transaction needs to be finished before we call the finish transaction.
/// @mockable
protocol InAppPurchaseSubscriptionClient {
    /// This function will fetch the current subscription state of type InAppPurchaseSubscriptionState
    ///
    /// - Parameter completion: The completion will be called, with a result
    func fetchSubscriptionState(completion: @escaping (Result<InAppPurchaseSubscriptionState, InAppPurchaseApplicationServiceError>) -> Void)

    /// This function will fetch product metadata
    ///
    /// - Parameter completion: The completion will be called, with a result
    func updateProductMetadata(completion: @escaping (Result<SKProduct?, InAppPurchaseApplicationServiceError>) -> Void)

    /// This property will return the local receipt data if any is available.
    var localReceiptData: Data? { get }

    func purchaseProduct(completion: @escaping (Result<SKPaymentTransaction, InAppPurchaseApplicationServiceError>) -> Void)

    func restorePurchases(completion: @escaping (Result<SKPaymentTransaction?, InAppPurchaseApplicationServiceError>) -> Void)

    func finishTransaction(_ transaction: SKPaymentTransaction)

    func completeTransactions(completion: @escaping (SKPaymentTransaction?) -> Void)
}
