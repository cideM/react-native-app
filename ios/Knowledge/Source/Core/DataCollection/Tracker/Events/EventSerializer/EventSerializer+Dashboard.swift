//
//  SegmentTrackingSerializer+Dashboard.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 06.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {
    func name(for event: Tracker.Event.Dashboard) -> String? {
        switch event {
        case .ccleDashboardButtonClicked:
            return "ccle_dashboard_button_clicked"
        case .ccleSearchStarted:
            return "ccle_search_started"
        case .ccleAmbossSubstanceClicked:
            return "ccle_amboss_substance_clicked"
        case .ccleGuidelineClicked:
            return "ccle_guideline_clicked"
        case .ccleCalculatorClicked:
            return "ccle_calculator_clicked"
        case .ccleFlowchartClicked:
            return "ccle_flowchart_clicked"
        case .dashboardDiscoveryCardsDisplayed:
            return "dashboard_discovery_cards_displayed"
        case .dashboardDiscoveryCardsDismissed:
            return "dashboard_discovery_cards_dismissed"
        case .dashboardDiscoveryClinicalReferenceClicked:
            return "dashboard_discovery_clinical_reference_clicked"
        case .dashboardDiscoveryClinicalToolClicked:
            return "dashboard_discovery_clinical_tool_clicked"
        case .dashboardCMECardClicked:
            return "dashboard_cme_clicked"
        }
    }

    func parameters(for event: Tracker.Event.Dashboard) -> [String: Any]? {
        switch event {
        case .dashboardDiscoveryCardsDisplayed, .dashboardDiscoveryCardsDismissed, .dashboardCMECardClicked: return nil
        case .dashboardDiscoveryClinicalReferenceClicked(let title, let link, let type):
            let parameters = SegmentParameter.Container<SegmentParameter.Dashboard.DiscoverAmboss>()

            parameters.set(title, for: .title)
            parameters.set(type, for: .type)
            parameters.set(link.absoluteString, for: .link)

            return parameters.data
        case .dashboardDiscoveryClinicalToolClicked(let title, let link, let type):
            let parameters = SegmentParameter.Container<SegmentParameter.Dashboard.DiscoverAmboss>()

            parameters.set(title, for: .title)
            parameters.set(type, for: .type)
            parameters.set(link.absoluteString, for: .link)

            return parameters.data
        case .ccleDashboardButtonClicked(let contentType):
            let parameters = SegmentParameter.Container<SegmentParameter.Dashboard.CCLE>()
            parameters.set(contentType.rawValue, for: .contentType)

            return parameters.data
        case .ccleSearchStarted(let contentType):
            let parameters = SegmentParameter.Container<SegmentParameter.Dashboard.CCLE>()
            parameters.set(contentType.rawValue, for: .contentType)

            return parameters.data
        case .ccleAmbossSubstanceClicked(let substanceId, let drugId, let monographId):
            let parameters = SegmentParameter.Container<SegmentParameter.Dashboard.CCLE>()
            parameters.set(substanceId, for: .substanceId)
            parameters.set(drugId, for: .drugId)
            parameters.set(monographId, for: .monographId)

            return parameters.data
        case .ccleGuidelineClicked(let targetUrl):
            let parameters = SegmentParameter.Container<SegmentParameter.Dashboard.CCLE>()
            parameters.set(targetUrl, for: .targetUrl)

            return parameters.data
        case .ccleCalculatorClicked(let mediaXid):
            let parameters = SegmentParameter.Container<SegmentParameter.Dashboard.CCLE>()
            parameters.set(mediaXid, for: .mediaXid)

            return parameters.data
        case .ccleFlowchartClicked(let mediaXid):
            let parameters = SegmentParameter.Container<SegmentParameter.Dashboard.CCLE>()
            parameters.set(mediaXid, for: .mediaXid)

            return parameters.data
        }
    }
}

extension SegmentParameter {
    enum Dashboard {
        // swiftlint:disable:next nesting
        enum CCLE: String {
            case contentType = "content_type"
            case mediaXid = "media_xid"
            case substanceId = "amboss_substance_id"
            case drugId = "branded_drug_id"
            case monographId = "monograph_id"
            case targetUrl = "target_url"
        }

        // swiftlint:disable:next nesting
        enum DiscoverAmboss: String {
            case title
            case link
            case type
        }
    }
}
