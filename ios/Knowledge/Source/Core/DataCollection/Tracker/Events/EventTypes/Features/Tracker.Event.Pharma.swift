//
//  Tracker.Event.Pharma.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 03.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

extension Tracker.Event {

    enum Pharma {
        // Drug List
        case availableDrugsFiltered(filterQuery: String,
                                    results: [PharmaFilterResult],
                                    pharmaAgentTitle: String,
                                    pharmaAgentId: String,
                                    pharmaCardTitle: String,
                                    pharmaCardXid: String,
                                    pharmaType: PharmaType = .drug,
                                    database: DatabaseType)

        case availableDrugsOpened(pharmaAgentTitle: String,
                                  pharmaAgentId: String,
                                  pharmaCardTitle: String,
                                  pharmaCardXid: String,
                                  pharmaType: PharmaType = .drug,
                                  database: DatabaseType)

        case pharmaBrandedDrugSelected(brandedDrugTitle: String,
                                       brandedDrugID: String,
                                       ambossSubstanceTitle: String,
                                       ambossSubstanceID: String,
                                       source: DataSource)

        case pharmaDrugsListClosed(pharmaAgentTitle: String,
                                   pharmaAgentId: String,
                                   pharmaCardTitle: String,
                                   pharmaCardXid: String,
                                   pharmaType: PharmaType = .drug,
                                   database: DatabaseType)

        // Agent or Drug Card
        case pharmaAmbossSubstanceOpened(ambossSubstanceId: String,
                                         ambossSubstanceTitle: String,
                                         brandedDrugId: String,
                                         brandedDrugTitle: String,
                                         roteHand: Bool,
                                         datasource: DataSource,
                                         document: SubstanceDocument,
                                         group: PocketCardGroup?)

        case pharmaPageDocumentSelected(ambossSubstanceId: String,
                                        document: SubstanceDocument)

        case pharmaPocketCardGroupSelected(ambossSubstanceId: String,
                                           group: PocketCardGroup)

        case pharmaCardClose(viewingDurationSeconds: Int,
                             pharmaAgentTitle: String,
                             pharmaAgentId: String,
                             pharmaCardTitle: String,
                             pharmaCardXid: String,
                             pharmaType: PharmaType = .drug,
                             database: DatabaseType)

        // Agent or Drug Card Sections
        case pharmaCardSectionCollapsed(sectionName: String,
                                        viewingDurationSeconds: Int? = 0,
                                        pharmaAgentTitle: String,
                                        pharmaAgentId: String,
                                        pharmaCardTitle: String,
                                        pharmaCardXid: String,
                                        pharmaType: PharmaType = .drug,
                                        database: DatabaseType)

        case pharmaAmbossSubstanceSectionExpanded(sectionName: String,
                                                  ambossSubstanceId: String,
                                                  ambossSubstanceTitle: String,
                                                  brandedDrugTitle: String,
                                                  brandedDrugId: String,
                                                  datasource: DataSource)

        // Feedback
        case pharmaFeedbackOpened(pharmaAgentTitle: String,
                                  pharmaAgentId: String,
                                  pharmaCardTitle: String,
                                  pharmaCardXid: String,
                                  pharmaType: PharmaType = .drug,
                                  database: DatabaseType)

        case pharmaFeedbackDismissed(pharmaAgentTitle: String,
                                     pharmaAgentId: String,
                                     pharmaCardTitle: String,
                                     pharmaCardXid: String,
                                     pharmaType: PharmaType = .drug,
                                     database: DatabaseType)

        case pharmaFeedbackSubmitted(feedbackText: String,
                                     pharmaAgentTitle: String,
                                     pharmaAgentId: String,
                                     pharmaCardTitle: String,
                                     pharmaCardXid: String,
                                     pharmaType: PharmaType = .drug,
                                     database: DatabaseType)

        case pharmaLinkedFileOpen(document: String,
                                  pharmaAgentTitle: String,
                                  pharmaAgentId: String,
                                  pharmaCardTitle: String,
                                  pharmaCardXid: String,
                                  pharmaType: PharmaType = .drug,
                                  database: DatabaseType)

        // Delete
        case pharmaOfflineDeleteAlertShown
        case pharmaOfflineDeleteDeclined
        case pharmaOfflineDeleteConfirmed(databaseVersion: String)
    }
}

enum PharmaType: String {
    case agent
    case drug
}

enum SubstanceDocument: String {
    case pocketCard = "pocket_card"
    case ifap
}

enum PocketCardGroup: String {
    case adult
    case pediatric

    init?(rawValue: String) {
        switch rawValue {
        case "pc_adult": self = .adult
        case "pc_pediatric": self = .pediatric
        default: return nil
        }
    }
}

// This is essentially the same as DatabaseType but going forward this type should be used
// Existing events will be migrated eventually ...
enum DataSource: String {
    case online
    case offline
}

enum DatabaseType: String {
    case online
    case offline
}

struct PharmaFilterResult {
    let id: String
    let link: [String: Any] = [:]
    let title: String
    let subtitle: String

    enum Parameter: String {
        case id
        case link
        case title
        case subtitle
    }

    func toDictionary() -> [String: Any] {
        [Parameter.id.rawValue: id,
         Parameter.link.rawValue: link,
         Parameter.title.rawValue: title,
         Parameter.subtitle.rawValue: subtitle]
    }
}
