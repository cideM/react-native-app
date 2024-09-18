//
//  Tracker.Event.Dashboard.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 06.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

extension Tracker.Event {
    enum Dashboard {
        case ccleDashboardButtonClicked(contentType: CCLEContentType)
        case ccleSearchStarted(contentType: CCLEContentType)
        case ccleAmbossSubstanceClicked(substanceId: String?,
                                   drugId: String?,
                                  monographId: String?)
        case ccleGuidelineClicked(targetUrl: String)
        case ccleCalculatorClicked(mediaXid: String)
        case ccleFlowchartClicked(mediaXid: String)

        case dashboardDiscoveryCardsDisplayed
        case dashboardDiscoveryCardsDismissed
        case dashboardDiscoveryClinicalReferenceClicked(title: String, link: URL, type: ClinicalReferenceType)
        case dashboardDiscoveryClinicalToolClicked(title: String, link: URL, type: ClinicalToolType)

        case dashboardCMECardClicked

        // swiftlint:disable:next nesting
        enum CCLEContentType: String {
            case pocketGuide = "PocketGuide"
            case calculator = "Calculator"
            case flowchart = "Flowchart"
            case pharmaCard = "PharmaCard"
            case monograph = "Monograph"
            case guidline = "Guideline"
        }

        // swiftlint:disable:next nesting
        enum ClinicalReferenceType: String {
            case article = "Article"
            case pharma = "Pharma"
        }

        // swiftlint:disable:next nesting
        enum ClinicalToolType: String {
            case calculator = "Calculator"
            case algorithm = "Algorithm"
        }
    }
}
