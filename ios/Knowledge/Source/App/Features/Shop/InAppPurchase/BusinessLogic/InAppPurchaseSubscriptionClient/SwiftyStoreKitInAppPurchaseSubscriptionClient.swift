//
//  SwiftyStoreKitInAppPurchaseSubscriptionClient.swift
//  AMBOSS Bibliothek
//
//  Created by CSH on 19.07.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import StoreKit
import SwiftyStoreKit

class SwiftyStoreKitInAppPurchaseSubscriptionClient: InAppPurchaseSubscriptionClient {

    var localReceiptData: Data? {
        SwiftyStoreKit.localReceiptData
    }

    private let isUsingProductionEndpoint: Bool
    private let sharedReceiptSecret: String
    private let productIdentifier: String

    required init(configuration: PurchaseConfiguration = AppConfiguration.shared) {
        self.isUsingProductionEndpoint = configuration.useInAppPurchaseProductionEndpoint
        self.sharedReceiptSecret = configuration.sharedReceiptSecret
        self.productIdentifier = configuration.ambossProUnlimitedIAPIdentifier
    }

    func fetchSubscriptionState(completion: @escaping (Result<InAppPurchaseSubscriptionState, InAppPurchaseApplicationServiceError>) -> Void) {
#if targetEnvironment(simulator)
        return completion(.success(.unsubscribed))
#else
        let service: AppleReceiptValidator.VerifyReceiptURLType = isUsingProductionEndpoint ? .production : .sandbox
        let appleValidator = AppleReceiptValidator(service: service, sharedSecret: sharedReceiptSecret)
        let productIdentifier = self.productIdentifier

        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: productIdentifier, inReceipt: receipt)
                switch purchaseResult {
                case .purchased: completion(.success(.subscribed))
                case .expired, .notPurchased: completion(.success(.unsubscribed))
                }
            case .error(let error):
                completion(.failure(.other(error)))
            }
        }
#endif
    }

    func updateProductMetadata(completion: @escaping (Result<SKProduct?, InAppPurchaseApplicationServiceError>) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo([productIdentifier]) { [weak self] result in
            guard let self = self else { return }

            if let error = result.error {
                completion(.failure(.other(error)))
            } else {
                let productMetadata = result.retrievedProducts.first { $0.productIdentifier == self.productIdentifier }
                completion(.success(productMetadata))
            }
        }
    }

    func purchaseProduct(completion: @escaping (Result<SKPaymentTransaction, InAppPurchaseApplicationServiceError>) -> Void) {
        SwiftyStoreKit.purchaseProduct(productIdentifier) { result in
            switch result {
            case .success(let purchase):
                if let transaction = purchase.transaction as? SKPaymentTransaction {
                    return completion(.success(transaction))
                } else {
                    return completion(.failure(.internalError("Expected a transaction of type SKPaymentTransaction")))
                }
            case .error(let error):
                return completion(.failure(.storeError(error)))
            case .deferred:
                break // Very unlikely to happen and hard to implement, hence skipped ...
            }
        }
    }

    func restorePurchases(completion: @escaping (Result<SKPaymentTransaction?, InAppPurchaseApplicationServiceError>) -> Void) {
        let productIdentifier = self.productIdentifier
        SwiftyStoreKit.restorePurchases { [weak self] results in
            guard let self = self else { return }

            if let restoredPurchase = results.restoredPurchases.first(where: { $0.productId == productIdentifier }),
                let transaction = restoredPurchase.transaction as? SKPaymentTransaction {

                self.fetchSubscriptionState { result in
                    switch result {
                    case .success(let state):
                        switch state {
                        case .subscribed:
                            completion(.success(state == .subscribed ? nil : transaction))
                        case .unsubscribed, .unknown:
                            completion(.success(state == .unsubscribed ? nil : transaction))
                        }
                    case .failure(let error):
                        completion(.failure(.other(error)))
                    }
                }

            // There should always be only one error in "restoreFailedPurchases". But since the API returns
            // an arry here, we have to make the best of it and forward whats most reasonable.
            // 1. Prefer handling errors with a specific product identifier because its likely more relevant ...
            } else if let failedPurchase = results.restoreFailedPurchases.first(where: { $0.1 == productIdentifier }) {
                completion(.failure(.storeError(failedPurchase.0)))

            // 2. In case there is no product identifier, forward any other error.
            // (This might be quite generic like "Cannot connect to iTunes Store" and so on ...)
            } else if let error = results.restoreFailedPurchases.compactMap({ $0.0 }).first {
                completion(.failure(.storeError(error)))

            } else {
                completion(.success(nil))
            }
        }
    }

    func completeTransactions(completion: @escaping (SKPaymentTransaction?) -> Void) {
        let productIdentifier = self.productIdentifier
        SwiftyStoreKit.completeTransactions(atomically: false) { purchases in

            let completedTransactionStates: [SKPaymentTransactionState] = [.purchased, .restored]
            let completedPurchases = purchases.filter { completedTransactionStates.contains($0.transaction.transactionState) }

            if let completedTransaction = completedPurchases.first(where: { $0.productId == productIdentifier })?.transaction as? SKPaymentTransaction {
                completion(completedTransaction)
            } else {
                completion(nil)
            }
        }
    }

    func finishTransaction(_ transaction: SKPaymentTransaction) {
        guard transaction.transactionState != .purchasing else {
            assertionFailure("transaction is currently purchasing and thus cannot be finished.")
            return
        }
        SwiftyStoreKit.finishTransaction(transaction)
    }
}
