//
//  MonitorContext.swift
//  Knowledge
//
//  Created by CSH on 18.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public enum MonitorContext: Int, CaseIterable {
    case none = 0
    case system /// Application bootstrapping, system events or similar
    case library /// Library issues, Updates, Autoupdates
    case pharma /// Pharma issues, Updates, Autoupdates
    case monographs /// US pharma
    case navigation /// User navigating around in the application, mostly used by the coordinators
    case synchronization /// All synchronization related things
    case migration
    case tracking
    case search
    case news
    case consent
    case inAppPurchase
    case api
    case crm
    case terms
}

extension MonitorContext: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none: return "undefined"
        case .system: return "system"
        case .library: return "library"
        case .pharma: return "pharma"
        case .monographs: return "monographs"
        case .navigation: return "navigation"
        case .synchronization: return "synchronization"
        case .migration: return "migration"
        case .tracking: return "tracking"
        case .search: return "search"
        case .news: return "news"
        case .consent: return "consent"
        case .inAppPurchase: return "inAppPurchase"
        case .api: return "api"
        case .crm: return "crm"
        case .terms: return "terms"
        }
    }
}
