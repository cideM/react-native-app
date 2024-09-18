//
//  ClinicalTool.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 22.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization

// sourcery: fixture:
enum ClinicalTool {
    // pocketGuides is a Clinical tool on the dashboard but it doesn't open the SERP page but rather it shows a webview with an app2weblink
    case pocketGuides
    case drugDatabase
    case flowcharts
    case calculators
    case guidelines

    private static let flowchartsKey = "flowchart"
    private static let calculatorsKey = "calculator"

    var title: String {
        switch self {
        case .pocketGuides:
            return L10n.Dashboard.Sections.ClinicalTools.PocketGuides.title
        case .drugDatabase:
            return L10n.Dashboard.Sections.ClinicalTools.DrugDatabase.title
        case .flowcharts:
            return L10n.Dashboard.Sections.ClinicalTools.Flowcharts.title
        case .calculators:
            return L10n.Dashboard.Sections.ClinicalTools.Calculators.title
        case .guidelines:
            return L10n.Dashboard.Sections.ClinicalTools.Guidelines.title
        }
    }

    var icon: UIImage {
        switch self {
        case .pocketGuides:
            return Asset.Icon.checkSquare.image
        case .drugDatabase:
            return Asset.Icon.pillIcon.image
        case .flowcharts:
            return Asset.Icon.flowcharts.image
        case .calculators:
            return Asset.Icon.calculators.image
        case .guidelines:
            return Asset.Icon.layers.image
        }
    }

    var subtitle: String? {
        switch self {
        case .drugDatabase:
            switch AppConfiguration.shared.appVariant {
            case .wissen: return L10n.Dashboard.Sections.ClinicalTools.DrugDatabase.subtitle
            case .knowledge: return nil
            }

        default:
            return nil
        }
    }

    var badgeTitle: String? {
        switch self {
        case .pocketGuides:
            return L10n.Dashboard.Sections.ClinicalTools.PocketGuides.badge
        default:
            return nil
        }
    }

    var additionalIcon: UIImage? {
        switch self {
        case .drugDatabase:
            switch AppConfiguration.shared.appVariant {
            case .wissen: return nil
            case .knowledge: return nil
            }
        default:
            return nil
        }
    }

    var additionalIconSize: CGSize? {
        switch self {
        case .drugDatabase:
            switch AppConfiguration.shared.appVariant {
            case .wissen: return CGSize(width: 39, height: 17)
            case .knowledge: return nil
            }
        default:
            return nil
        }
    }

    var contentCount: Int {
        switch AppConfiguration.shared.appVariant {
        case .knowledge:
            switch self {
            case .pocketGuides: return 20
            case .drugDatabase: return 1613
            case .flowcharts: return 81
            case .calculators: return 139
            case .guidelines: return 1554
            }
        case .wissen:
            switch self {
            case .pocketGuides: return 0
            case .drugDatabase: return 1938
            case .flowcharts: return 112
            case .calculators: return 60
            case .guidelines: return 2666
            }
        }
    }

    var searchPlaceholder: String {
        switch self {
        case .pocketGuides:
            return ""
        case .drugDatabase:
            return L10n.Dashboard.Sections.ClinicalTools.DrugDatabase.searchPlaceholder
        case .flowcharts:
            return L10n.Dashboard.Sections.ClinicalTools.Flowcharts.searchPlaceholder
        case .calculators:
            return L10n.Dashboard.Sections.ClinicalTools.Calculators.searchPlaceholder
        case .guidelines:
            return L10n.Dashboard.Sections.ClinicalTools.Guidelines.searchPlaceholder
        }
    }

    var searchFilters: [String] {
        switch self {
        case .flowcharts: return [Self.flowchartsKey]
        case .calculators: return [Self.calculatorsKey]
        default: return []
        }
    }

    var searchQueryPrefix: String {
        var contentKey: String
        switch AppConfiguration.shared.appVariant {
        case .knowledge:
            switch self {
            case .pocketGuides:
                return ""
            case .drugDatabase:
                contentKey = "drugs"
            case .flowcharts:
                contentKey = "flowcharts"
            case .calculators:
                contentKey = "calculators"
            case .guidelines:
                contentKey = "guidelines"
            }
        case .wissen:
            switch self {
            case .pocketGuides:
                return ""
            case .drugDatabase:
                contentKey = "arzneimittel"
            case .flowcharts:
                contentKey = "flussdiagramme"
            case .calculators:
                contentKey = "rechner"
            case .guidelines:
                contentKey = "leitlinien"
            }
        }
        return "in:\(contentKey) "
    }

    var searchType: SearchType {
        switch self {
        case .pocketGuides:
            return .all
        case .drugDatabase:
            return .pharma
        case .flowcharts:
            return .media
        case .calculators:
            return .media
        case .guidelines:
            return .guideline
        }
    }
}
