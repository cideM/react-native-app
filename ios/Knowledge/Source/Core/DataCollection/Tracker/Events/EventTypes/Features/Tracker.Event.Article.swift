//
//  Tracker.Event+Article.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 23.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension Tracker.Event {

    enum Article {

        enum Referrer { // swiftlint:disable:this nesting
            case instantResults
            case searchResults
            case dashboardRecentlyReadList
            case recentlyReadList
            case favoritesList
            case learnedList
            case ownExtensions
            case library
            case article
            case pharmaCard
            case deepLink
            case feed
        }

        // Views
        case articleOpened(articleID: String,
                           title: String,
                           options: LearningCardOptions? = nil)
        case articleClosed(articleID: String,
                           title: String,
                           viewingDuration: Int) // -> duration is in seconds
        case articleSelected(articleID: String,
                             referrer: Referrer)

        // Sections
        case articleExpandSection(articleID: String,
                                  title: String,
                                  sectionID: String)
        case articleCollapseSection(articleID: String,
                                    title: String,
                                    sectionID: String)
        case articleCollapseAllSections(articleID: String,
                                        title: String)
        case articleExpandAllSections(articleID: String,
                                      title: String)
        case articleAnchorIdInvalid(articleID: String,
                                    id: String)
        case articleParticleIdInvalid(articleID: String,
                                      id: String)

        case articleCreateSessionClicked(articleID: String)

        // Favorites
        case articleFavoriteSet(articleID: String)
        case articleFavoriteRemoved(articleID: String)

        // High yield
        case articleHighYieldToggled(articleID: String,
                                     isEnabled: Bool)

        // Highlighting
        case articleHighlightingToggled(articleID: String,
                                        isEnabled: Bool)

        // Learned
        case articleLearnedToggledOff(articleID: String,
                                      locatedOn: String) // can be on article or list
        case articleLearnedToggledOn(articleID: String,
                                     locatedOn: String)

        // Learning radar
        case articleLearningRadarToggledOff(articleID: String)
        case articleLearningRadarToggledOn(articleID: String)

        // Search
        case articleInPageSearchOpened(articleID: String)
        case articleFindInPageEdited(articleID: String,
                                     searchSessionID: String?,
                                     findInPageSessionID: String,
                                     currentInput: String,
                                     totalMatches: Int,
                                     currentMatch: Int)

        // Share
        case articleShareOpened(articleID: String)
        case articleShareSent(articleID: String)

        case articleNavigatedForward
        case articleNavigatedBackward

        // Popup
        case tooltipOpened(articleTitle: String,
                           tooltipType: String?)

        // Options
        case articleOptionsMenuOpened(articleID: String,
                                      userStage: Stage)

        // Dosage tooltips
        case pharmaDosageShown(articleID: String,
                                 dosageID: String,
                                 source: DataSource)

        case articleDosageOpenFailed(articleID: String,
                                     dosageID: String,
                                     error: String)

        case articleDosageLinkClicked(articleID: String,
                                      dosageID: Int,
                                      substanceID: Int,
                                      drugID: Int?)
    }
}
