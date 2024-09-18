//
//  Configuration.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/26/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

// WORKAROUND:(@mockable)
// GRDB also exposes a protocol named "Configuration"
// Hence adding a module prefix here
// More info: https://github.com/uber/mockolo/pull/96

// sourcery: fixture:
enum AppVariant {
    case knowledge
    case wissen
}

/// @mockable(module: prefix = Knowledge_DE)
protocol Configuration: URLConfiguration,
                        PurchaseConfiguration,
                        TrackingConfiguration,
                        FeatureConfiguration,
                        ConsentConfiguration,
                        UserInterfaceConfiguration {

    var appVariant: AppVariant { get }
}

protocol UserInterfaceConfiguration {
    var languageCode: String { get }
    var popoverWidth: CGFloat { get }
}

protocol FeatureConfiguration {

    var hasStudyObjective: Bool { get }
    var availableUserStages: [UserStage] { get }
    var searchActivityType: String { get }
}

protocol PurchaseConfiguration {

    var sharedReceiptSecret: String { get }
    var ambossProUnlimitedIAPIdentifier: String { get }
    var useInAppPurchaseProductionEndpoint: Bool { get }
}

protocol TrackingConfiguration {

    var segmentAnalyticsWriteKey: String { get }
    var segmentAnalyticsFlushAt: Int { get }
    var segmentTrackApplicationLifecycleEvents: Bool { get }
    var segmentProxyURLHost: String { get }
    var segmentProxyURLPath: String { get }

    var adjustAppToken: String { get }

    var brazeAPIKey: String { get }
    var brazeEndpoint: String { get }
}

protocol URLConfiguration {

    var webBaseURL: URL { get }
    var graphQLURL: URL { get }
    var restBaseURL: URL { get }
    var articleBaseURL: URL { get }
    var sharedLearningCardBaseURL: URL { get }
    var meditricksRefererUrl: URL { get }
    var smartzoomRefererUrl: URL { get }
    var manageSharedExtensionsURL: URL { get }
    var qBankAppStoreLink: URL { get }
    var legalNoticeURL: URL { get }
    var privacyURL: URL { get }
    var termsAndConditionsURL: URL { get }
    var liabilityNoticeURL: URL { get }
    var inAppPurchaseManageSubscriptionURL: URL { get }
    var searchNoResultsFeedbackForm: URL { get }

    var qBankQuestionSessionPathComponent: String { get }
    var qBankQuestionSessionURLQueryItems: [String: String] { get }

    var cmeURL: URL { get }
}

protocol ConsentConfiguration {

    var usercentricsSettingsId: String { get }
    var isConsentDialogEnabled: Bool { get }
    var userCentricsAdjustTemplateID: String { get }
}
