//
//  AmbossSubscriptionState.swift
//  Interfaces
//
//  Created by Aamir Suhial Mir on 03.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct AmbossSubscriptionState {
    public let canPurchaseInAppSubscription: Bool
    public let hasActiveInAppSubscription: Bool

    // sourcery: fixture:
    public init(canPurchaseInAppSubscription: Bool, hasActiveInAppSubscription: Bool) {
        self.canPurchaseInAppSubscription = canPurchaseInAppSubscription
        self.hasActiveInAppSubscription = hasActiveInAppSubscription
    }
}
