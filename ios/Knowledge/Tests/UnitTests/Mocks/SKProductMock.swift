//
//  SKProductMock.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 07.03.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import StoreKit

final class SKProductMock: SKProduct {
    override var productIdentifier: String {
        .fixture()
    }

    override var price: NSDecimalNumber {
        NSDecimalNumber(floatLiteral: Double.fixture())
    }

    override var priceLocale: Locale {
        Locale(identifier: .fixture())
    }
}
