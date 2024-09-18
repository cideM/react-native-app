//
//  RemoteConfigType.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 29.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
protocol RemoteConfigType: AnyObject {
    func fetch(completion: @escaping (Result<Void, RemoteConfigSynchError>) -> Void)
    var requestTimeout: NSNumber { get }
    var searchAdConfig: SearchAdConfig { get }
    var areMonographsEnabled: Bool { get }
    var pharmaDosageTooltipV1Enabled: Bool { get }
    var pharmaDosageNGDENavigationEnabled: Bool { get }
    var brazeEnabled: Bool { get }
    var contentCardsEnabled: Bool { get }
    var iap5DayTrialRemoved: Bool { get }
    var medicationLinkReplacements: [(snippet: SnippetIdentifier, monograph: MonographIdentifier)]? { get }
    var termsReAcceptanceEnabled: Bool { get }
    var dashboardCMELinkEnabled: Bool { get }
}

class SearchAdConfig: Decodable {
    let enabled: Bool
    let position: Int
    let pharmaOpensToHide: Int
    let timeForResetDays: Int

    init(enabled: Bool = true, position: Int = 2, pharmaOpensToHide: Int = 10, timeForResetDays: Int = 60) {
        self.enabled = enabled
        self.position = position
        self.pharmaOpensToHide = pharmaOpensToHide
        self.timeForResetDays = timeForResetDays
    }
}
