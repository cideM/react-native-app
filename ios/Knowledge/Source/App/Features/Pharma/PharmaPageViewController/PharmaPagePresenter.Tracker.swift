//
//  PharmaPresenter.Tracker.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 04.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

extension PharmaPagePresenter {

    struct CardData {
        let title: String // Represents drug title
        let identifier: String // Represnts drug id
        let substanceTitle: String
        let substanceIdentifier: String
        let type: PharmaType = .drug
        let riskInformation: Bool
        var openedAt = Date()
        var sectionOpenedAt: [String: Date] = [:]
    }

    class Tracker {

        var source: Metrics.Source?

        var databaseType: DatabaseType {
            // "source" should never be nil when this is called, adding a default value to please the compiler
            assert(source != nil)
            switch source ?? .online {
            case .online: return .online
            case .offline: return .offline
            }
        }

        // This is the same as DatabaseType but just different naming
        // We're slowly migrating events to this version ...
        var dataSource: DataSource {
            // "source" should never be nil when this is called, adding a default value to please the compiler
            assert(source != nil)
            switch source ?? .online {
            case .online: return .online
            case .offline: return .offline
            }
        }

        private let trackingProvider: TrackingType
        private var cardData: CardData?

        internal init(trackingProvider: TrackingType = resolve()) {
            self.trackingProvider = trackingProvider
        }

        func timeSpent(openedAt: Date, closedAt: Date = Date()) -> Int {
            Int(closedAt.timeIntervalSince(openedAt).rounded(.up))
        }
    }
}

extension PharmaPagePresenter.Tracker {
    func fillCardDataOfCard(cardData: PharmaPagePresenter.CardData) {
        self.cardData = cardData
    }
}

extension PharmaPagePresenter.Tracker {
    func trackFileOpen(document: String) {
        guard let cardData = cardData else { return }
        self.trackingProvider.track(.pharmaLinkedFileOpen(document: document,
                                                                   pharmaAgentTitle: cardData.substanceTitle,
                                                                   pharmaAgentId: cardData.substanceIdentifier,
                                                                   pharmaCardTitle: cardData.identifier,
                                                                   pharmaCardXid: cardData.identifier,
                                                                   pharmaType: cardData.type,
                                                                   database: databaseType))
    }
}

extension PharmaPagePresenter.Tracker {

    func trackAvailableDrugsFiltered(query: String, results: [PharmaFilterResult]) {
        guard let cardData = cardData else { return }
        self.trackingProvider.track(.availableDrugsFiltered(filterQuery: query,
                                                                     results: results,
                                                                     pharmaAgentTitle: cardData.substanceTitle,
                                                                     pharmaAgentId: cardData.substanceIdentifier,
                                                                     pharmaCardTitle: cardData.title,
                                                                     pharmaCardXid: cardData.identifier,
                                                                     pharmaType: cardData.type,
                                                                     database: databaseType))
    }

    func trackAvailableDrugsOpened() {
        guard let cardData = cardData else { return }
        self.trackingProvider.track(.availableDrugsOpened(pharmaAgentTitle: cardData.substanceTitle,
                                                                   pharmaAgentId: cardData.substanceIdentifier,
                                                                   pharmaCardTitle: cardData.title,
                                                                   pharmaCardXid: cardData.identifier,
                                                                   pharmaType: cardData.type,
                                                                   database: databaseType))
    }

    func trackAvailableDrugsSelected(drugTitle: String, drugId: String) {
        guard let cardData = cardData else { return }
        self.trackingProvider.track(.pharmaBrandedDrugSelected(brandedDrugTitle: drugTitle,
                                                               brandedDrugID: drugId,
                                                               ambossSubstanceTitle: cardData.substanceTitle,
                                                               ambossSubstanceID: cardData.substanceIdentifier,
                                                               source: dataSource))
    }

    func trackPharmaDrugsListClosed() {
        guard let cardData = cardData else { return }
        self.trackingProvider.track(.pharmaDrugsListClosed(pharmaAgentTitle: cardData.substanceTitle,
                                                                     pharmaAgentId: cardData.substanceIdentifier,
                                                                     pharmaCardTitle: cardData.title,
                                                                     pharmaCardXid: cardData.identifier,
                                                                     pharmaType: cardData.type,
                                                                     database: databaseType))
    }
}

extension PharmaPagePresenter.Tracker {

    func trackPharmaAmbossSubstanceOpened(document: SubstanceDocument, group: String?) {
        cardData?.openedAt = Date()
        guard let cardData = cardData else { return }

        self.trackingProvider.track(
            .pharmaAmbossSubstanceOpened(ambossSubstanceId: cardData.substanceIdentifier,
                                         ambossSubstanceTitle: cardData.substanceTitle,
                                         brandedDrugId: cardData.identifier,
                                         brandedDrugTitle: cardData.title,
                                         roteHand: cardData.riskInformation,
                                         datasource: dataSource,
                                         document: document,
                                         group: PocketCardGroup(rawValue: group ?? ""))
        )
    }

    func trackPharmaPageDocumentSelected(document: SubstanceDocument) {
        guard let cardData = cardData else { return }
        self.trackingProvider.track(
            .pharmaPageDocumentSelected(ambossSubstanceId: cardData.substanceIdentifier,
                                        document: document)
        )
    }

    func trackPocketCardGroupSelected(group: String?) {
        guard  let cardData = cardData, let group = PocketCardGroup(rawValue: group ?? "") else { return }
        self.trackingProvider.track(
            .pharmaPocketCardGroupSelected(ambossSubstanceId: cardData.substanceIdentifier, group: group)
        )
    }

    func trackPharmaCardClose() {
        guard let cardData = cardData else { return }
        self.trackingProvider.track(.pharmaCardClose(viewingDurationSeconds: timeSpent(openedAt: cardData.openedAt),
                                                     pharmaAgentTitle: cardData.substanceTitle,
                                                     pharmaAgentId: cardData.substanceIdentifier,
                                                     pharmaCardTitle: cardData.title,
                                                     pharmaCardXid: cardData.identifier,
                                                     pharmaType: cardData.type,
                                                     database: databaseType))
    }

    func trackSectionToggled(section: PharmaViewData.SectionViewData, isExpanded: Bool) {
        switch section {
        case .section(let pharmaSectionViewItem):
            if isExpanded {
                trackPharmaAmbossSubstanceSectionExpanded(sectionName: pharmaSectionViewItem.title)
            } else {
                trackPharmaCardSectionCollapsed(sectionName: pharmaSectionViewItem.title)
            }
        default: break
        }
    }

    func trackPharmaCardSectionCollapsed(sectionName: String) {
        guard let cardData = cardData else { return }
        if let sectionOpenedAt = cardData.sectionOpenedAt[sectionName] {
            let timeSpentOnSection = timeSpent(openedAt: sectionOpenedAt)
            self.trackingProvider.track(.pharmaCardSectionCollapsed(sectionName: sectionName,
                                                                             viewingDurationSeconds: timeSpentOnSection,
                                                                             pharmaAgentTitle: cardData.substanceTitle,
                                                                             pharmaAgentId: cardData.substanceIdentifier,
                                                                             pharmaCardTitle: cardData.title,
                                                                             pharmaCardXid: cardData.identifier,
                                                                             pharmaType: cardData.type,
                                                                             database: databaseType))
        }
    }

    func trackPharmaAmbossSubstanceSectionExpanded(sectionName: String) {
        cardData?.sectionOpenedAt[sectionName] = Date()
        guard let cardData = cardData else { return }
        self.trackingProvider.track(.pharmaAmbossSubstanceSectionExpanded(sectionName: sectionName,
                                                                          ambossSubstanceId: cardData.substanceIdentifier,
                                                                          ambossSubstanceTitle: cardData.substanceTitle,
                                                                          brandedDrugTitle: cardData.title,
                                                                          brandedDrugId: cardData.identifier,
                                                                          datasource: dataSource))
    }

}

extension PharmaPagePresenter.Tracker {

    func trackPharmaFeedbackOpened() {
        guard let cardData = cardData else { return }
        self.trackingProvider.track(.pharmaFeedbackOpened(pharmaAgentTitle: cardData.substanceTitle,
                                                                   pharmaAgentId: cardData.substanceIdentifier,
                                                                   pharmaCardTitle: cardData.title,
                                                                   pharmaCardXid: cardData.identifier,
                                                                   pharmaType: cardData.type,
                                                                   database: databaseType))
    }

    func trackPharmaFeedbackSubmitted(feedbackText: String) {
        guard let cardData = cardData else { return }
        self.trackingProvider.track(.pharmaFeedbackSubmitted(feedbackText: feedbackText,
                                                                      pharmaAgentTitle: cardData.substanceTitle,
                                                                      pharmaAgentId: cardData.substanceIdentifier,
                                                                      pharmaCardTitle: cardData.title,
                                                                      pharmaCardXid: cardData.identifier,
                                                                      pharmaType: cardData.type,
                                                                      database: databaseType))
    }

    /// This event is not used being that `Zendesk` does not trigger an event when the feedback view is dismissed.
    func trackPharmaFeedbackDismissed() {
        guard let cardData = cardData else { return }
        self.trackingProvider.track(.pharmaFeedbackDismissed(pharmaAgentTitle: cardData.substanceTitle,
                                                                      pharmaAgentId: cardData.substanceIdentifier,
                                                                      pharmaCardTitle: cardData.title,
                                                                      pharmaCardXid: cardData.identifier,
                                                                      pharmaType: cardData.type,
                                                                      database: databaseType))
    }
}

extension PharmaPagePresenter.Tracker {

    func trackArticleSelected(articleId: LearningCardIdentifier) {
        self.trackingProvider.track(.articleSelected(articleID: articleId.value, referrer: .pharmaCard))
    }
}
