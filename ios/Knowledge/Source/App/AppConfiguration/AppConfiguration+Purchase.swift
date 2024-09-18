//
//  AppConfiguration+Purchase.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 20.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

extension AppConfiguration: PurchaseConfiguration {

    var sharedReceiptSecret: String {
        switch appVariant {
        case .wissen: return "5df86f138dea44bcad1ce70387df3f41"
        case .knowledge: return "4bf20da4a2954f76998d5231bbd53143"
        }
    }

    var ambossProUnlimitedIAPIdentifier: String {
        switch appVariant {
        case .wissen: return "de.miamed.AMBOSS_Bibliothek.pro.unlimited"
        case .knowledge: return "us.miamed.amboss_knowledge.pro.unlimited"
        }
    }

    var useInAppPurchaseProductionEndpoint: Bool {
        #if DEBUG
        return false
        #elseif QA
        return false
        #else
        return true
        #endif
    }
}
