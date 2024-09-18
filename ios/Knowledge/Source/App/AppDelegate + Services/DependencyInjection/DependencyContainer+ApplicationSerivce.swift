//
//  DependencyContainer+ApplicationSerivce.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 14.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import DIKit

extension DependencyContainer {
    private static let attributionTrackingApplicationService: AttributionTrackingApplicationServiceType = shared.resolve()
    static var applicationService = module {
        single { BrazeApplicationService() as BrazeApplicationServiceType }
        single { ZendeskApplicationService() as SupportApplicationService }
        single { InAppPurchaseApplicationService(subscriptionClient: SwiftyStoreKitInAppPurchaseSubscriptionClient()) as InAppPurchaseApplicationServiceType }
        single { ShortcutsService() as ShortcutsServiceType }
        single { UsercentricsConsentApplicationService(consentChangeListeners: [attributionTrackingApplicationService]) as ConsentApplicationServiceType }
        single { AdjustAttributionTrackingApplicationService() as AttributionTrackingApplicationServiceType }
        single { AppearanceApplicationService() as AppearanceApplicationServiceType }
    }
}
