//
//  SegmentTrackingSerializer+Article.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 23.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {

    func name(for event: Tracker.Event.Article) -> String? {
        switch event {
        case .articleOpened: return "article_opened"
        case .articleClosed: return "article_closed"
        case .articleSelected: return "article_selected"
        case .articleExpandSection: return "article_expand_section"
        case .articleCollapseSection: return "article_collapse_section"
        case .articleCollapseAllSections: return "article_collapse_all_sections"
        case .articleExpandAllSections: return "article_expand_all_sections"
        case .articleCreateSessionClicked: return "article_create_session_clicked"
        case .articleFavoriteSet: return "article_favorite_set"
        case .articleFavoriteRemoved: return "article_favorite_removed"
        case .articleHighYieldToggled: return "article_high_yield_toggled"
        case .articleHighlightingToggled: return "article_highlighting_toggled"
        case .articleLearnedToggledOff: return "article_learned_toggled_off"
        case .articleLearnedToggledOn: return "article_learned_toggled_on"
        case .articleLearningRadarToggledOff: return "article_learning_radar_toggled_off"
        case .articleLearningRadarToggledOn: return "article_learning_radar_toggled_on"
        case .articleInPageSearchOpened: return "article_in_page_search_opened"
        case .articleFindInPageEdited: return "article_find_in_page_edited"
        case .articleShareOpened: return "article_share_opened"
        case .articleShareSent: return "article_share_sent"
        case .articleNavigatedForward: return "article_navigated_forward"
        case .articleNavigatedBackward: return "article_navigated_backward"
        case .tooltipOpened: return "tooltip_open"
        case .articleOptionsMenuOpened: return "article_options_menu_opened"
        case .pharmaDosageShown: return "pharma_dosage_shown"
        case .articleDosageOpenFailed: return "article_dosage_open_failed"
        case .articleDosageLinkClicked: return "article_dosage_link_clicked"
        case .articleAnchorIdInvalid: return "article_anchor_xid_invalid"
        case .articleParticleIdInvalid: return "article_particle_xid_invalid"
        }
    }

    func parameters(for event: Tracker.Event.Article) -> [String: Any]? {
        let parameters = SegmentParameter.Container<SegmentParameter.Article>()
        switch event {
        case .articleFavoriteRemoved(let articleID),
             .articleFavoriteSet(let articleID),
             .articleInPageSearchOpened(let articleID),
             .articleShareOpened(let articleID),
             .articleShareSent(let articleID),
             .articleCreateSessionClicked(let articleID),
             .articleLearningRadarToggledOn(let articleID),
             .articleLearningRadarToggledOff(let articleID):
            parameters.set(articleID, for: .articleXid)

        case .articleSelected(let articleID, let referrer):
            parameters.set(articleID, for: .articleXid)
            parameters.set(value(for: referrer), for: .referrer)

        case .articleLearnedToggledOff(let articleID, let locatedOn),
             .articleLearnedToggledOn(let articleID, let locatedOn):
            parameters.set(articleID, for: .articleXid)
            parameters.set(locatedOn, for: .locatedOn)

        case .articleHighYieldToggled(let articleID, let isEnabled),
             .articleHighlightingToggled(let articleID, let isEnabled):
            parameters.set(articleID, for: .articleXid)
            parameters.set(isEnabled ? "on" : "off", for: .toggleState)

        case .articleCollapseSection(let articleID, let title, let sectionID),
             .articleExpandSection(let articleID, let title, let sectionID):
            parameters.set(articleID, for: .articleXid)
            parameters.set(title, for: .articleTitle)
            parameters.set(sectionID, for: .sectionXid)

        case .articleClosed(let articleID, let title, let seconds):
            parameters.set(articleID, for: .articleXid)
            parameters.set(title, for: .articleTitle)
            parameters.set(seconds, for: .viewingDurationSeconds)

        case .articleExpandAllSections(let articleID, let title),
             .articleCollapseAllSections(let articleID, let title):
            parameters.set(articleID, for: .articleXid)
            parameters.set(title, for: .articleTitle)

        case .articleOpened(let articleID, let title, let options):
            parameters.set(articleID, for: .articleXid)
            parameters.set(title, for: .articleTitle)
            parameters.set(value(for: options), for: .viewOptions)

        case .articleParticleIdInvalid(let articleID, let id):
            parameters.set(articleID, for: .articleXid)
            parameters.set(id, for: .particleXid)

        case .articleAnchorIdInvalid(let articleID, let id):
            parameters.set(articleID, for: .articleXid)
            parameters.set(id, for: .anchorXid)

        case .articleNavigatedForward,
             .articleNavigatedBackward:
            return nil

        case .tooltipOpened(let articleTitle, let tooltipType):
            parameters.set(articleTitle, for: .learningCardTitle)
            parameters.set(tooltipType, for: .tooltipType)

        case .articleOptionsMenuOpened(let articleID, let userStage):
            parameters.set(articleID, for: .articleXid)
            parameters.set(userStage, for: .userStage)

        case .pharmaDosageShown(let articleID, let dosageId, let source):
            parameters.set(articleID, for: .articleXid)
            parameters.set(dosageId, for: .dosageId)
            parameters.set(source, for: .datasource)

        case .articleDosageOpenFailed(let articleID, let dosageId, let error):
            parameters.set(articleID, for: .articleXid)
            parameters.set(dosageId, for: .dosageId)
            parameters.set(String(describing: error), for: .error)

        case .articleDosageLinkClicked(let articleID, let dosageID, let substanceID, let drugID):
            parameters.set(articleID, for: .articleXid)
            parameters.set(dosageID, for: .dosageId)
            parameters.set(drugID, for: .brandedDrugId)
            parameters.set(substanceID, for: .substanceId)

        case .articleFindInPageEdited(let articleID, let searchSessionID, let findInPageSessionID, let currentInput, let totalMatches, let currentMatch):
            parameters.set(articleID, for: .articleXid)
            parameters.set(searchSessionID, for: .searchSessionID)
            parameters.set(findInPageSessionID, for: .findInPageSessionID)
            parameters.set(currentInput, for: .currentInput)
            parameters.set(totalMatches, for: .totalMatches)
            parameters.set(currentMatch, for: .currentMatch)

        }

        return parameters.data
    }

    private func value(for referrer: Tracker.Event.Article.Referrer) -> String {
        switch referrer {
        case .instantResults: return "instant_results"
        case .favoritesList: return "favorites_list"
        case .learnedList: return "learned_list"
        case .library: return "library"
        case .recentlyReadList: return "recently_read_list"
        case .ownExtensions: return "own_extensions"
        case .searchResults: return "search_results"
        case .dashboardRecentlyReadList: return "dashboard_recently_read_list"
        case .article: return "article"
        case .pharmaCard: return "pharma_card"
        case .deepLink: return "deepLink"
        case .feed: return "feed"
        }
    }

    private func value(for options: LearningCardOptions?) -> [String: Any]? {
        guard let options = options else { return nil }

        return [
            "high_yield": options.isHighYieldModeOn,
            "highlighting": options.isHighlightingModeOn,
            "learning_radar": options.isOnLearningRadarOn,
            "preclinic_focus": options.isPhysikumFokusModeOn
        ]
    }
}

extension SegmentParameter {
    enum Article: String {
        case articleXid = "article_xid"
        case articleTitle = "article_title"
        case viewOptions = "view_options"
        case viewingDurationSeconds = "viewing_duration_seconds"
        case sectionXid = "section_xid"
        case anchorXid = "anchor_xid"
        case particleXid = "particle_xid"
        case toggleState = "toggle_state"
        case locatedOn = "located_on"
        case referrer
        case learningCardTitle = "learning_card_title"
        case tooltipType = "tooltip_type"
        case userStage = "user_stage"
        case dosageId = "dosage_id"
        case error = "error"
        case datasource = "datasource"
        case database = "database"
        case searchSessionID = "search_session_id"
        case findInPageSessionID = "find_in_page_session_id"
        case currentInput = "current_input"
        case totalMatches = "total_matches"
        case currentMatch = "current_match"
        case brandedDrugId = "branded_drug_id"
        case substanceId = "substance_id"
    }
}

extension Tracker.Event.Article {

    enum Stage: String {
        case clinic = "Clinic"
        case physician = "Physician"
        case preclinic = "Preclinic"
    }
}
