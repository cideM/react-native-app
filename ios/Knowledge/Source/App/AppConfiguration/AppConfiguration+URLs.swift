//
//  AppConfiguration+URLs.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 20.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation

extension AppConfiguration: URLConfiguration {

    var webBaseURL: URL {
        switch appVariant {
        case .wissen: return URL(string: "https://www.amboss.com/de")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "https://www.amboss.com/us")! // swiftlint:disable:this force_unwrapping
        }
    }

    var graphQLURL: URL {
        if let graphQLURLBaseString = ProcessInfo.processInfo.environment["graphQLBaseURL"],
           let graphQLBaseURL = URL(string: graphQLURLBaseString) {
            return graphQLBaseURL
        } else {
            switch appVariant {
            case .wissen: return URL(string: "https://www.amboss.com/de/api/graphql")! // swiftlint:disable:this force_unwrapping
            case .knowledge: return URL(string: "https://www.amboss.com/us/api/graphql")! // swiftlint:disable:this force_unwrapping
            }
        }
    }

    var restBaseURL: URL {
        if let restBaseURLString = ProcessInfo.processInfo.environment["restBaseURL"],
           let restBaseURL = URL(string: restBaseURLString) {
            return restBaseURL
        } else {
            switch appVariant {
            case .wissen: return URL(string: "https://mobile-api-de.amboss.com/")! // swiftlint:disable:this force_unwrapping
            case .knowledge: return URL(string: "https://mobile-api-us.amboss.com/")! // swiftlint:disable:this force_unwrapping
            }
        }
    }

    var articleBaseURL: URL {
        switch appVariant {
        case .wissen: return URL(string: "https://next.amboss.com/de/article")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "https://next.amboss.com/us/article")! // swiftlint:disable:this force_unwrapping
        }
    }

    var sharedLearningCardBaseURL: URL {
        switch appVariant {
        case .wissen: return URL(string: "https://www.amboss.com/de/wissen")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "https://www.amboss.com/us/knowledge")! // swiftlint:disable:this force_unwrapping
        }
    }

    var meditricksRefererUrl: URL {
        switch appVariant {
        case .wissen: return URL(string: "http://ios.knowledge.de.amboss.com")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "http://ios.knowledge.us.amboss.com")! // swiftlint:disable:this force_unwrapping
        }
    }

    var smartzoomRefererUrl: URL {
        switch appVariant {
        case .wissen: return URL(string: "http://ios.knowledge.de.amboss.com")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "http://ios.knowledge.us.amboss.com")! // swiftlint:disable:this force_unwrapping
        }
    }

    var manageSharedExtensionsURL: URL {
        switch appVariant {
        case .wissen: return URL(string: "https://www.amboss.com/de/app2web/manageSharedExtensions")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "https://www.amboss.com/us/app2web/manageSharedExtensions")! // swiftlint:disable:this force_unwrapping
        }
    }

    var qBankAppStoreLink: URL {
        switch appVariant {
        case .wissen: return URL(string: "itms-apps://itunes.apple.com/de/app/amboss-kreuzen-f%C3%BCr-mediziner/id1076182652?mt=8")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "itms-apps://itunes.apple.com/de/app/amboss-qbank-usmle/id1169403493?mt=8")! // swiftlint:disable:this force_unwrapping
        }
    }

    var legalNoticeURL: URL {
        switch appVariant {
        case .wissen: return URL(string: "https://www.amboss.com/de/impressum?no-header")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "https://www.amboss.com/us/legal/legal-notice?no-header")! // swiftlint:disable:this force_unwrapping
        }
    }

    var privacyURL: URL {
        switch appVariant {
        case .wissen: return  URL(string: "https://www.amboss.com/de/datenschutz?no-header")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "https://www.amboss.com/us/privacy?no-header")! // swiftlint:disable:this force_unwrapping
        }
    }

    var termsAndConditionsURL: URL {
        switch appVariant {
        case .wissen: return URL(string: "https://www.amboss.com/de/agb?no-header")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "https://www.amboss.com/us/terms?no-header")! // swiftlint:disable:this force_unwrapping
        }
    }

    var liabilityNoticeURL: URL {
        switch appVariant {
        case .wissen: return URL(string: "https://www.amboss.com/de/disclaimer?no-header")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "https://www.amboss.com/us/legal/legal-notice?no-header")! // swiftlint:disable:this force_unwrapping
        }
    }

    var inAppPurchaseManageSubscriptionURL: URL {
        URL(string: "https://apple.co/2Th4vqI")! // swiftlint:disable:this force_unwrapping
    }

    var searchNoResultsFeedbackForm: URL {
        switch appVariant {
        case .wissen: return URL(string: "https://docs.google.com/forms/d/1pJLxbVkkgqdyBPEWG9QHhvXgxGpYjGwexgXkDLifW3Y/viewform?edit_requested=true")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "https://docs.google.com/forms/d/1jrAMEzSxxbokzL5n6xjOau11DvDEZpnIItldb0isExA/viewform?edit_requested=true")! // swiftlint:disable:this force_unwrapping
        }
    }

    var qBankQuestionSessionPathComponent: String {
        "/collection/learningcard/"
    }

    var qBankQuestionSessionURLQueryItems: [String: String] {
        ["mode": "question"]
    }

    var cmeURL: URL {
        switch appVariant {
        case .wissen: return URL(string: "https://www.amboss.com/de/app2web/courses")! // swiftlint:disable:this force_unwrapping
        case .knowledge: return URL(string: "https://www.amboss.com/us/app2web/courses")! // swiftlint:disable:this force_unwrapping
        }
    }
}
