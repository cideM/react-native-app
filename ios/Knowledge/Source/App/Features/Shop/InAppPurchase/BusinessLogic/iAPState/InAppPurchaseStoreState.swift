//
//  InAppPurchaseStoreState.swift
//  AMBOSS Bibliothek
//
//  Created by CSH on 18.07.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import StoreKit

enum InAppPurchaseStoreState: Equatable {
    case loading
    case readyToBuy(SKProduct)
    case unlinkedInAppPurchaseSubscription
    case activeInAppPurchaseSubscription
    case activeExternalSubscription
    case temporaryError // offer a try again button
    case permanentError // offer a contact support button
}
