//
//  Tracker.Event.InAppPurchase.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 16.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension Tracker.Event {

    enum InAppPurchase {
        case noAccessBuyLicense
        case iapStoreOpened
        case iapStoreLoaded
        case iapStoreClosed
        case iapStorePerksPageChanged(info: InAppPurchaseInfo, pageNumber: Int)
        case iapSubscribeButtonClicked(info: InAppPurchaseInfo)
        case iapRestoreButtonClicked(info: InAppPurchaseInfo)
        case iapSubscribeStarted(info: InAppPurchaseInfo)
        case iapRestoreStarted(info: InAppPurchaseInfo)
        case iapRestoreCancelled(info: InAppPurchaseInfo)
        case iapRestoreSucceeded(info: InAppPurchaseInfo)
        case iapRestoreFailed(info: InAppPurchaseInfo, errorMessage: String)
        case iapSubscribeCancelled(info: InAppPurchaseInfo)
        case iapSubscribeSucceeded(info: InAppPurchaseInfo)
        case iapSubscribeFailed(info: InAppPurchaseInfo, errorMessage: String)
        case iapLinkStarted(info: InAppPurchaseInfo)
        case iapLinkSucceeded(info: InAppPurchaseInfo)
        case iapLinkFailed(info: InAppPurchaseInfo, errorMessage: String)
        case iapCancelSubscriptionClicked(info: InAppPurchaseInfo)
        case iapLinkButtonClicked(info: InAppPurchaseInfo)
        case iapAccessUpdated(info: InAppPurchaseInfo)
        case iapAccessUpdateFailed(info: InAppPurchaseInfo, errorMessage: String)
        case iapProductMetaDataUpdateSucceeded(info: InAppPurchaseInfo)
        case iapProductMetaDataUpdateFailed(info: InAppPurchaseInfo, errorMessage: String)
    }
}
