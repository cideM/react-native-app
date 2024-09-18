//
//  PurchaseEntitlementsDidChangeNotification.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 27.05.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

struct InAppPurchaseInfoDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: InAppPurchaseInfo
    let newValue: InAppPurchaseInfo
}
