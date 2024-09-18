//
//  InAppPurchaseInfo.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 27.05.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Network
import StoreKit

struct InAppPurchaseInfo: Equatable {
    let subscriptionState: InAppPurchaseSubscriptionState
    let canPurchase: Bool
    let hasActiveIAPSubscription: Bool
    let hasProductMetadata: Bool
    let productIdentifier: String?
    let localizedPriceValue: Float?
    let localizedPriceCurrency: String?
    let hasTrialAccess: Bool

    // sourcery: fixture:
    init(subscriptionState: InAppPurchaseSubscriptionState = .unknown,
         canPurchase: Bool = false,
         hasActiveIAPSubcription: Bool = false,
         hasProductMetadata: Bool = false,
         productIdentifier: String? = nil,
         localizedPriceValue: Float? = nil,
         localizedPriceCurrency: String? = nil,
         hasTrialAccess: Bool = false) {

        self.subscriptionState = subscriptionState
        self.canPurchase = canPurchase
        self.hasActiveIAPSubscription = hasActiveIAPSubcription
        self.hasProductMetadata = hasProductMetadata
        self.productIdentifier = productIdentifier
        self.localizedPriceValue = localizedPriceValue
        self.localizedPriceCurrency = localizedPriceCurrency
        self.hasTrialAccess = hasTrialAccess
    }
}

extension InAppPurchaseInfo {

    func with(subscriptionState: InAppPurchaseSubscriptionState) -> InAppPurchaseInfo {
        InAppPurchaseInfo(subscriptionState: subscriptionState,
                          canPurchase: self.canPurchase,
                          hasActiveIAPSubcription: self.hasActiveIAPSubscription,
                          hasProductMetadata: self.hasProductMetadata,
                          productIdentifier: self.productIdentifier,
                          localizedPriceValue: self.localizedPriceValue,
                          localizedPriceCurrency: self.localizedPriceCurrency,
                          hasTrialAccess: self.hasTrialAccess)
    }

    func with(canPurchase: Bool) -> InAppPurchaseInfo {
        InAppPurchaseInfo(subscriptionState: self.subscriptionState,
                          canPurchase: canPurchase,
                          hasActiveIAPSubcription: self.hasActiveIAPSubscription,
                          hasProductMetadata: self.hasProductMetadata,
                          productIdentifier: self.productIdentifier,
                          localizedPriceValue: self.localizedPriceValue,
                          localizedPriceCurrency: self.localizedPriceCurrency,
                          hasTrialAccess: self.hasTrialAccess)
    }

    func with(hasActiveIAPSubcription: Bool) -> InAppPurchaseInfo {
        InAppPurchaseInfo(subscriptionState: self.subscriptionState,
                          canPurchase: self.canPurchase,
                          hasActiveIAPSubcription: hasActiveIAPSubcription,
                          hasProductMetadata: self.hasProductMetadata,
                          productIdentifier: self.productIdentifier,
                          localizedPriceValue: self.localizedPriceValue,
                          localizedPriceCurrency: self.localizedPriceCurrency,
                          hasTrialAccess: self.hasTrialAccess)
    }

    func with(hasProductMetadata: Bool) -> InAppPurchaseInfo {
        InAppPurchaseInfo(subscriptionState: self.subscriptionState,
                          canPurchase: self.canPurchase,
                          hasActiveIAPSubcription: self.hasActiveIAPSubscription,
                          hasProductMetadata: hasProductMetadata,
                          productIdentifier: self.productIdentifier,
                          localizedPriceValue: self.localizedPriceValue,
                          localizedPriceCurrency: self.localizedPriceCurrency,
                          hasTrialAccess: self.hasTrialAccess)
    }

    func with(productIdentifier: String?) -> InAppPurchaseInfo {
        InAppPurchaseInfo(subscriptionState: self.subscriptionState,
                          canPurchase: self.canPurchase,
                          hasActiveIAPSubcription: self.hasActiveIAPSubscription,
                          hasProductMetadata: self.hasProductMetadata,
                          productIdentifier: productIdentifier,
                          localizedPriceValue: self.localizedPriceValue,
                          localizedPriceCurrency: self.localizedPriceCurrency,
                          hasTrialAccess: self.hasTrialAccess)
    }

    func with(localizedPriceValue: Float?) -> InAppPurchaseInfo {
        InAppPurchaseInfo(subscriptionState: self.subscriptionState,
                          canPurchase: self.canPurchase,
                          hasActiveIAPSubcription: self.hasActiveIAPSubscription,
                          hasProductMetadata: self.hasProductMetadata,
                          productIdentifier: self.productIdentifier,
                          localizedPriceValue: localizedPriceValue,
                          localizedPriceCurrency: self.localizedPriceCurrency,
                          hasTrialAccess: self.hasTrialAccess)
    }

    func with(localizedPriceCurrency: String?) -> InAppPurchaseInfo {
        InAppPurchaseInfo(subscriptionState: self.subscriptionState,
                          canPurchase: self.canPurchase,
                          hasActiveIAPSubcription: self.hasActiveIAPSubscription,
                          hasProductMetadata: self.hasProductMetadata,
                          productIdentifier: self.productIdentifier,
                          localizedPriceValue: self.localizedPriceValue,
                          localizedPriceCurrency: localizedPriceCurrency,
                          hasTrialAccess: self.hasTrialAccess)
    }

    func with(hasTrialAccess: Bool) -> InAppPurchaseInfo {
        InAppPurchaseInfo(subscriptionState: self.subscriptionState,
                          canPurchase: self.canPurchase,
                          hasActiveIAPSubcription: self.hasActiveIAPSubscription,
                          hasProductMetadata: self.hasProductMetadata,
                          productIdentifier: self.productIdentifier,
                          localizedPriceValue: self.localizedPriceValue,
                          localizedPriceCurrency: self.localizedPriceCurrency,
                          hasTrialAccess: hasTrialAccess)
    }
}
