//
//  InAppPurchaseApplicationServiceError.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 04.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import StoreKit

enum InAppPurchaseApplicationServiceError: Error {
    case internalError(String)
    case storeError(SKError)
    case other(Error)
}
