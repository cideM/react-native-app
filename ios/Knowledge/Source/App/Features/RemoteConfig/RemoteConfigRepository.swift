//
//  RemoteConfigRepository.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 25.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
protocol RemoteConfigRepositoryType {

    var requestTimeout: TimeInterval { get }

    var searchAdConfig: SearchAdConfig { get }

    var areMonographsEnabled: Bool { get }

    var pharmaDosageTooltipV1Enabled: Bool { get }

    var pharmaDosageNGDENavigationEnabled: Bool { get }

    var brazeEnabled: Bool { get }

    var contentCardsEnabled: Bool { get }

    var iap5DayTrialRemoved: Bool { get }

    // This is supposed to be in temporary use only as long as this experiment runs ...
    // https://miamed.atlassian.net/browse/PHEX-1351
    var medicationLinkReplacements: [(snippet: SnippetIdentifier, monograph: MonographIdentifier)]? { get }

    var termsReAcceptanceEnabled: Bool { get }

    var dashboardCMELinkEnabled: Bool { get }
}

final class RemoteConfigRepository: RemoteConfigRepositoryType {
    private let remoteConfig: RemoteConfigType
    private let appVariant: AppVariant

    init(remoteConfig: RemoteConfigType = resolve(), appVariant: AppVariant = AppConfiguration.shared.appVariant) {
        self.remoteConfig = remoteConfig
        self.appVariant = appVariant
    }

    var requestTimeout: TimeInterval {
        remoteConfig.requestTimeout.doubleValue
    }

    var searchAdConfig: SearchAdConfig {
        remoteConfig.searchAdConfig
    }

    var areMonographsEnabled: Bool {
        switch appVariant {
        case .knowledge: return remoteConfig.areMonographsEnabled
        case .wissen: return false
        }
    }

    var pharmaDosageTooltipV1Enabled: Bool {
        remoteConfig.pharmaDosageTooltipV1Enabled
    }

    var pharmaDosageNGDENavigationEnabled: Bool {
        remoteConfig.pharmaDosageNGDENavigationEnabled
    }

    var brazeEnabled: Bool {
        remoteConfig.brazeEnabled
    }

    var contentCardsEnabled: Bool {
        remoteConfig.contentCardsEnabled
    }

    var medicationLinkReplacements: [(snippet: SnippetIdentifier, monograph: MonographIdentifier)]? {
        remoteConfig.medicationLinkReplacements
    }

    var iap5DayTrialRemoved: Bool {
        remoteConfig.iap5DayTrialRemoved
    }

    var termsReAcceptanceEnabled: Bool {
        remoteConfig.termsReAcceptanceEnabled
    }

    var dashboardCMELinkEnabled: Bool {
        remoteConfig.dashboardCMELinkEnabled
    }
}
