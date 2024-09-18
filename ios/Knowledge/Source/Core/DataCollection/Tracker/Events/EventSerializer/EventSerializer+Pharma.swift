//
//  SegmentTrackingSerializer+Pharma.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 03.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {

    func name(for event: Tracker.Event.Pharma) -> String? {
        switch event {
        case .availableDrugsOpened: return "available_drugs_opened"
        case .pharmaAmbossSubstanceOpened: return "pharma_amboss_substance_opened"
        case .pharmaPageDocumentSelected: return "pharma_amboss_substance_document_selected"
        case .pharmaPocketCardGroupSelected: return "pharma_pocket_card_group_selected"
        case .pharmaCardClose: return "pharma_card_close"
        case .pharmaCardSectionCollapsed: return "pharma_card_section_collapsed"
        case .pharmaAmbossSubstanceSectionExpanded: return "pharma_amboss_substance_section_expanded"
        case .pharmaFeedbackOpened: return "pharma_feedback_opened"
        case .pharmaFeedbackDismissed: return "pharma_feedback_dismissed"
        case .pharmaFeedbackSubmitted: return "pharma_feedback_submitted"
        case .pharmaLinkedFileOpen: return "pharma_linked_file_open"
        case .pharmaOfflineDeleteAlertShown: return "pharma_offline_delete_confirmation_shown"
        case .pharmaOfflineDeleteDeclined: return "pharma_offline_delete_declined"
        case .pharmaOfflineDeleteConfirmed: return "pharma_offline_delete_confirmed"
        case .availableDrugsFiltered: return "available_drugs_filtered"
        case .pharmaBrandedDrugSelected: return "pharma_branded_drug_selected"
        case .pharmaDrugsListClosed: return "pharma_drugs_list_closed"
        }
    }

    func parameters(for event: Tracker.Event.Pharma) -> [String: Any]? {
        let parameters = SegmentParameter.Container<SegmentParameter.Pharma>()
        switch event {
        case .availableDrugsFiltered(filterQuery: let filterQuery,
                                     results: let results,
                                     pharmaAgentTitle: let pharmaAgentTitle,
                                     pharmaAgentId: let pharmaAgentId,
                                     pharmaCardTitle: let pharmaCardTitle,
                                     pharmaCardXid: let pharmaCardXid,
                                     pharmaType: let pharmaType,
                                     database: let database):
            parameters.set(filterQuery, for: .filterQuery)
            parameters.set(results.map { $0.toDictionary() }, for: .results)
            parameters.set(pharmaAgentTitle, for: .pharmaAgentTitle)
            parameters.set(pharmaAgentId, for: .pharmaAgentId)
            parameters.set(pharmaCardTitle, for: .pharmaCardTitle)
            parameters.set(pharmaCardXid, for: .pharmaCardXid)
            parameters.set(pharmaType, for: .pharmaType)
            parameters.set(database, for: .databaseType)

        case .availableDrugsOpened(pharmaAgentTitle: let pharmaAgentTitle,
                                   pharmaAgentId: let pharmaAgentId,
                                   pharmaCardTitle: let pharmaCardTitle,
                                   pharmaCardXid: let pharmaCardXid,
                                   pharmaType: let pharmaType,
                                   database: let database):
            parameters.set(pharmaAgentTitle, for: .pharmaAgentTitle)
            parameters.set(pharmaAgentId, for: .pharmaAgentId)
            parameters.set(pharmaCardTitle, for: .pharmaCardTitle)
            parameters.set(pharmaCardXid, for: .pharmaCardXid)
            parameters.set(pharmaType, for: .pharmaType)
            parameters.set(database, for: .databaseType)

        case .pharmaBrandedDrugSelected(brandedDrugTitle: let brandedDrugTitle,
                                        brandedDrugID: let brandedDrugID,
                                        ambossSubstanceTitle: let ambossSubstanceTitle,
                                        ambossSubstanceID: let ambossSubstanceID,
                                        source: let source):
            parameters.set(ambossSubstanceTitle, for: .ambossSubstanceTitle)
            parameters.set(ambossSubstanceID, for: .ambossSubstanceID)
            parameters.set(brandedDrugID, for: .brandedDrugID)
            parameters.set(brandedDrugTitle, for: .brandedDrugTitle)
            parameters.set(source, for: .datasource)

        case .pharmaDrugsListClosed(pharmaAgentTitle: let pharmaAgentTitle,
                                    pharmaAgentId: let pharmaAgentId,
                                    pharmaCardTitle: let pharmaCardTitle,
                                    pharmaCardXid: let pharmaCardXid,
                                    pharmaType: let pharmaType,
                                    database: let database):
            parameters.set(pharmaAgentTitle, for: .pharmaAgentTitle)
            parameters.set(pharmaAgentId, for: .pharmaAgentId)
            parameters.set(pharmaCardTitle, for: .pharmaCardTitle)
            parameters.set(pharmaCardXid, for: .pharmaCardXid)
            parameters.set(pharmaType, for: .pharmaType)
            parameters.set(database, for: .databaseType)

        case .pharmaAmbossSubstanceOpened(let ambossSubstanceId,
                                          let ambossSubstanceTitle,
                                          let brandedDrugId,
                                          let brandedDrugTitle,
                                          let roteHand,
                                          let datasource,
                                          let document,
                                          let group):
            parameters.set(ambossSubstanceId, for: .ambossSubstanceID)
            parameters.set(ambossSubstanceTitle, for: .ambossSubstanceTitle)
            parameters.set(brandedDrugId, for: .brandedDrugID)
            parameters.set(brandedDrugTitle, for: .brandedDrugTitle)
            parameters.set(roteHand, for: .riskInformation)
            parameters.set(datasource, for: .datasource)
            parameters.set(document, for: .substanceDocument)
            parameters.set(group, for: .pocketCardGroup)

        case .pharmaPageDocumentSelected(let ambossSubstanceId, let document):
            parameters.set(ambossSubstanceId, for: .ambossSubstanceID)
            parameters.set(document, for: .substanceDocument)

        case .pharmaPocketCardGroupSelected(let ambossSubstanceId, let group):
            parameters.set(ambossSubstanceId, for: .ambossSubstanceID)
            parameters.set(group, for: .pocketCardGroup)

        case .pharmaCardClose(viewingDurationSeconds: let viewingDurationSeconds,
                              pharmaAgentTitle: let pharmaAgentTitle,
                              pharmaAgentId: let pharmaAgentId,
                              pharmaCardTitle: let pharmaCardTitle,
                              pharmaCardXid: let pharmaCardXid,
                              pharmaType: let pharmaType,
                              database: let database):
            parameters.set(viewingDurationSeconds, for: .viewingDurationSeconds)
            parameters.set(pharmaAgentTitle, for: .pharmaAgentTitle)
            parameters.set(pharmaAgentId, for: .pharmaAgentId)
            parameters.set(pharmaCardTitle, for: .pharmaCardTitle)
            parameters.set(pharmaCardXid, for: .pharmaCardXid)
            parameters.set(pharmaType, for: .pharmaType)
            parameters.set(database, for: .databaseType)

        case .pharmaCardSectionCollapsed(sectionName: let sectionName,
                                         viewingDurationSeconds: let viewingDurationSeconds,
                                         pharmaAgentTitle: let pharmaAgentTitle,
                                         pharmaAgentId: let pharmaAgentId,
                                         pharmaCardTitle: let pharmaCardTitle,
                                         pharmaCardXid: let pharmaCardXid,
                                         pharmaType: let pharmaType,
                                         database: let database):
            parameters.set(sectionName, for: .sectionName)
            parameters.set(viewingDurationSeconds, for: .viewingDurationSeconds)
            parameters.set(pharmaAgentTitle, for: .pharmaAgentTitle)
            parameters.set(pharmaAgentId, for: .pharmaAgentId)
            parameters.set(pharmaCardTitle, for: .pharmaCardTitle)
            parameters.set(pharmaCardXid, for: .pharmaCardXid)
            parameters.set(pharmaType, for: .pharmaType)
            parameters.set(database, for: .databaseType)

        case .pharmaAmbossSubstanceSectionExpanded(let sectionName,
                                                   let ambossSubstanceId,
                                                   let ambossSubstanceTitle,
                                                   let brandedDrugTitle,
                                                   let brandedDrugId,
                                                   let datasource):
            parameters.set(sectionName, for: .sectionName)
            parameters.set(ambossSubstanceId, for: .ambossSubstanceID)
            parameters.set(ambossSubstanceTitle, for: .ambossSubstanceTitle)
            parameters.set(brandedDrugTitle, for: .brandedDrugTitle)
            parameters.set(brandedDrugId, for: .brandedDrugID)
            parameters.set(datasource, for: .datasource)

        case .pharmaFeedbackOpened(pharmaAgentTitle: let pharmaAgentTitle,
                                   pharmaAgentId: let pharmaAgentId,
                                   pharmaCardTitle: let pharmaCardTitle,
                                   pharmaCardXid: let pharmaCardXid,
                                   pharmaType: let pharmaType,
                                   database: let database):
            parameters.set(pharmaAgentTitle, for: .pharmaAgentTitle)
            parameters.set(pharmaAgentId, for: .pharmaAgentId)
            parameters.set(pharmaCardTitle, for: .pharmaCardTitle)
            parameters.set(pharmaCardXid, for: .pharmaCardXid)
            parameters.set(pharmaType, for: .pharmaType)
            parameters.set(database, for: .databaseType)

        case .pharmaFeedbackDismissed(pharmaAgentTitle: let pharmaAgentTitle,
                                      pharmaAgentId: let pharmaAgentId,
                                      pharmaCardTitle: let pharmaCardTitle,
                                      pharmaCardXid: let pharmaCardXid,
                                      pharmaType: let pharmaType,
                                      database: let database):
            parameters.set(pharmaAgentTitle, for: .pharmaAgentTitle)
            parameters.set(pharmaAgentId, for: .pharmaAgentId)
            parameters.set(pharmaCardTitle, for: .pharmaCardTitle)
            parameters.set(pharmaCardXid, for: .pharmaCardXid)
            parameters.set(pharmaType, for: .pharmaType)
            parameters.set(database, for: .databaseType)

        case .pharmaFeedbackSubmitted(feedbackText: let feedbackText,
                                      pharmaAgentTitle: let pharmaAgentTitle,
                                      pharmaAgentId: let pharmaAgentId,
                                      pharmaCardTitle: let pharmaCardTitle,
                                      pharmaCardXid: let pharmaCardXid,
                                      pharmaType: let pharmaType,
                                      database: let database):
            parameters.set(feedbackText, for: .feedbackText)
            parameters.set(pharmaAgentTitle, for: .pharmaAgentTitle)
            parameters.set(pharmaAgentId, for: .pharmaAgentId)
            parameters.set(pharmaCardTitle, for: .pharmaCardTitle)
            parameters.set(pharmaCardXid, for: .pharmaCardXid)
            parameters.set(pharmaType, for: .pharmaType)
            parameters.set(database, for: .databaseType)

        case .pharmaLinkedFileOpen(document: let document,
                                   pharmaAgentTitle: let pharmaAgentTitle,
                                   pharmaAgentId: let pharmaAgentId,
                                   pharmaCardTitle: let pharmaCardTitle,
                                   pharmaCardXid: let pharmaCardXid,
                                   pharmaType: let pharmaType,
                                   database: let database):
            parameters.set(document, for: .document)
            parameters.set(pharmaAgentTitle, for: .pharmaAgentTitle)
            parameters.set(pharmaAgentId, for: .pharmaAgentId)
            parameters.set(pharmaCardTitle, for: .pharmaCardTitle)
            parameters.set(pharmaCardXid, for: .pharmaCardXid)
            parameters.set(pharmaType, for: .pharmaType)
            parameters.set(database, for: .databaseType)

        case .pharmaOfflineDeleteConfirmed(databaseVersion: let databaseVersion):
            parameters.set(databaseVersion, for: .databaseVersion)
        case .pharmaOfflineDeleteAlertShown, .pharmaOfflineDeleteDeclined:
            break
        }
        return parameters.data
    }
}
extension SegmentParameter {
    enum Pharma: String {
        case applicationForm = "application_form"
        case embryotoxLabel = "embryotox_label"
        case feedbackText = "feedback_text"
        case pharmaType = "pharma_type"
        case ambossSubstanceTitle = "amboss_substance_title"
        case ambossSubstanceID = "amboss_substance_id"
        case brandedDrugID = "branded_drug_id"
        case brandedDrugTitle = "branded_drug_title"
        case pharmaCardTitle = "pharma_card_title"
        case pharmaCardXid = "pharma_card_xid"
        case riskInformation = "rote_hand"
        case sectionName = "section_name"
        case targetUrl = "target_url"
        case viewingDurationSeconds = "viewing_duration_seconds"
        case datasource = "datasource"
        case substanceDocument = "amboss_substance_document"
        case pocketCardGroup = "pocket_card_group"
        case databaseType = "database_type"
        case databaseVersion = "pharma_version"
        case results = "results"
        case pharmaAgentId = "pharma_agent_id"
        case pharmaAgentTitle = "pharma_agent_title"
        case positionInList = "position_in_list"
        case filterQuery = "filter_query"
        case document = "document"
    }
}
