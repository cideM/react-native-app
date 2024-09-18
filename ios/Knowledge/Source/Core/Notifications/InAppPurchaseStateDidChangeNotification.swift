//
//  InAppPurchaseStateDidChangeNotification.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 04.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct InAppPurchaseStateDidChangeNotification: AutoNotificationRepresentable {
    let oldValue: InAppPurchaseStoreState
    let newValue: InAppPurchaseStoreState
}
