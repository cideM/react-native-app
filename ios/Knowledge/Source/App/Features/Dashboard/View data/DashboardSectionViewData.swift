//
//  DashboardSectionViewData.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 16.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit
import Domain
import Foundation
import DesignSystem

struct DashboardSectionViewData {

    enum Item {
        case article(ArticleDashboardItem)
        case clinicalTool(ClinicalToolDashboardItem)
        case contentCard(ContentCardView.ViewData)
        case text(String)
        case externalLink(text: String, url: URL, image: UIImage? = nil)
    }

    struct ArticleDashboardItem {
        let learningCardMetaItem: LearningCardMetaItem
        let isFavorite: Bool
        let isLearned: Bool
        let tapClosure: (LearningCardMetaItem) -> Void
    }

    struct ClinicalToolDashboardItem {
        let clinicalTool: ClinicalTool
        let tapClosure: (ClinicalTool) -> Void
    }

    let title: String?
    let items: [Item]
    let showsHeader: Bool
    let hasSeparator: Bool
    let canHaveAllButton: Bool
    let tapAllClosure: (() -> Void)?

    var hasAllButton: Bool {
        canHaveAllButton && !items.isEmpty
    }

}

enum DashboardSection {
    case clinicalTools(DashboardSectionViewData)
    case recents(DashboardSectionViewData)
    case highlights(DashboardSectionViewData)
    case externalLink(DashboardSectionViewData)
}
