//
//  SegmentTrackingSerializer+InAppPurchase.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 16.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {

    func name(for event: Tracker.Event.InAppPurchase) -> String? {
        switch event {
        case .noAccessBuyLicense: return "no_access_buy_license"
        case .iapStoreOpened: return "iap_store_opened"
        case .iapStoreLoaded: return "iap_store_loaded"
        case .iapStoreClosed: return "iap_store_closed"
        case .iapStorePerksPageChanged: return "iap_store_perks_page_changed"
        case .iapSubscribeButtonClicked: return "iap_subscribe_button_clicked"
        case .iapRestoreButtonClicked: return "iap_restore_button_clicked"
        case .iapSubscribeStarted: return "iap_subscribe_started"
        case .iapRestoreStarted: return "iap_restore_started"
        case .iapRestoreCancelled: return "iap_restore_cancelled"
        case .iapRestoreSucceeded: return "iap_restore_succeeded"
        case .iapRestoreFailed: return "iap_restore_failed"
        case .iapSubscribeCancelled: return "iap_subscribe_cancelled"
        case .iapSubscribeSucceeded: return "iap_subscribe_succeeded"
        case .iapSubscribeFailed: return "iap_subscribe_failed"
        case .iapLinkStarted: return "iap_link_started"
        case .iapLinkSucceeded: return "iap_link_succeeded"
        case .iapLinkFailed: return "iap_link_failed"
        case .iapCancelSubscriptionClicked: return "iap_cancel_subscription_clicked"
        case .iapLinkButtonClicked: return "iap_link_button_clicked"
        case .iapAccessUpdated: return "iap_access_updated"
        case .iapAccessUpdateFailed: return "iap_access_update_failed"
        case .iapProductMetaDataUpdateSucceeded: return "iap_product_meta_data_update_succeeded"
        case .iapProductMetaDataUpdateFailed: return "iap_product_meta_data_update_failed"
        }
    }

    func parameters(for event: Tracker.Event.InAppPurchase) -> [String: Any]? {
        let parameters = SegmentParameter.Container<SegmentParameter.InAppPurchase>()
        switch event {
        case .noAccessBuyLicense,
             .iapStoreOpened,
             .iapStoreLoaded,
             .iapStoreClosed:
            return nil

        case .iapSubscribeButtonClicked(let info),
             .iapRestoreButtonClicked(let info),
             .iapSubscribeStarted(let info),
             .iapRestoreStarted(let info),
             .iapRestoreCancelled(let info),
             .iapRestoreSucceeded(let info),
             .iapSubscribeCancelled(let info),
             .iapSubscribeSucceeded(let info),
             .iapLinkStarted(let info),
             .iapLinkSucceeded(let info),
             .iapCancelSubscriptionClicked(let info),
             .iapLinkButtonClicked(let info),
             .iapAccessUpdated(let info),
             .iapProductMetaDataUpdateSucceeded(let info):
            parameters.set(value(for: info.subscriptionState), for: .subscriptionState)
            parameters.set(info.canPurchase ? "true" : "false", for: .canPurchase)
            parameters.set(info.hasActiveIAPSubscription ? "true" : "false", for: .hasActiveIAPSubscription)
            parameters.set(info.hasProductMetadata ? "available" : "unknown", for: .productMetadata)
            parameters.set(info.productIdentifier, for: .productIdentifier)
            parameters.set(info.localizedPriceValue, for: .localizedPriceValue)
            parameters.set(info.localizedPriceCurrency, for: .localizedPriceCurrency)

        case .iapStorePerksPageChanged(let info, let pageNumber):
            parameters.set(value(for: info.subscriptionState), for: .subscriptionState)
            parameters.set(info.canPurchase ? "true" : "false", for: .canPurchase)
            parameters.set(info.hasActiveIAPSubscription ? "true" : "false", for: .hasActiveIAPSubscription)
            parameters.set(info.hasProductMetadata ? "available" : "unknown", for: .productMetadata)
            parameters.set(pageNumber, for: .pageNumber)

        case .iapLinkFailed(let info, let errorMessage),
             .iapRestoreFailed(let info, let errorMessage),
             .iapAccessUpdateFailed(let info, let errorMessage),
             .iapSubscribeFailed(let info, let errorMessage),
             .iapProductMetaDataUpdateFailed(let info, let errorMessage):
            parameters.set(value(for: info.subscriptionState), for: .subscriptionState)
            parameters.set(info.canPurchase ? "true" : "false", for: .canPurchase)
            parameters.set(info.hasActiveIAPSubscription ? "true" : "false", for: .hasActiveIAPSubscription)
            parameters.set(info.hasProductMetadata ? "available" : "unknown", for: .productMetadata)
            parameters.set(errorMessage, for: .errorMessage)
        }
        return parameters.data
    }

    private func value(for state: InAppPurchaseSubscriptionState) -> String {
        switch state {
        case .unknown: return "unknown"
        case .subscribed: return "subscribed"
        case .unsubscribed: return "unsubscribed"
        }
    }
}

extension SegmentParameter {
    enum InAppPurchase: String {
        case pageNumber = "new_page"
        case canPurchase
        case subscriptionState = "apple_subscription"
        case hasActiveIAPSubscription
        case productMetadata = "productmetadata"
        case errorMessage = "error_message"
        case productIdentifier = "product_identifier"
        case localizedPriceValue = "localized_price_value"
        case localizedPriceCurrency = "localized_price_currency"
    }
}
