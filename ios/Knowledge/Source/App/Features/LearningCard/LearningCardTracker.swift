//
//  LearningCardTracker.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 28.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

/// @mockable
protocol LearningCardTrackerType {

    var trackingProvider: TrackingType { get }

    func trackLearningRadar(isEnabled: Bool)
    func trackInArticleSearchOpened()
    func trackArticleFindInPageEdited(currentInput: String?, totalMatches: Int, currentMatch: Int)
    func trackPresentShareSheet()
    func trackShareSent()
    func trackIsLearned(isEnabled: Bool)
    func trackHighlighting(isEnabled: Bool)
    func trackHighYield(isEnabled: Bool)
    func trackArticleFavorite(isFavorite: Bool)
    func trackArticleSelected()
    func trackStartReading(for identifier: LearningCardIdentifier)
    func trackEndReading(for identifier: LearningCardIdentifier, with reading: LearningCardReading?)
    func trackTooltipOpen(tooltipType: String?)
    func trackSectionOpened(sectionID: String)
    func trackSectionClosed(sectionID: String)
    func trackOpenAllSections()
    func trackCloseAllSections()
    func trackArticleAnchorIdInvalid(articleID: String, id: String)
    func trackArticleParticleIdInvalid(articleID: String, id: String)
    func trackArticleDosageOpened(dosageID: DosageIdentifier, source: DataSource)
    func trackArticleDosageOpenFailed(dosageID: DosageIdentifier, error: Error)
    func trackNavigatedForward()
    func trackNavigatedBackward()
    func trackShowImageExplanations(imageID: ImageResourceIdentifier)
    func trackHideImageExplanations(imageID: ImageResourceIdentifier)
    func trackShowImageOverlay(imageID: ImageResourceIdentifier)
    func trackHideImageOverlay(imageID: ImageResourceIdentifier)
    func trackShowSmartZoom(imageID: ImageResourceIdentifier)
    func trackCloseSmartZoom(imageID: ImageResourceIdentifier)
    func trackShowImageMediaviewer(imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?)
    func trackCloseImageMediaviewer(imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?)
    func trackShowImageMediaviewer(articleId: String?, imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?)
    func trackCloseImageMediaviewer(articleId: String?, imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?)
    func trackShowVideoMediaviewer(url: URL)
    func trackShowVideoMediaviewer(articleId: String?, url: URL)
    func trackNoAccessBuyLicense()
    func trackOptionsMenuOpened()

    func renewFindInPageSessionID()
}

class LearningCardTracker: LearningCardTrackerType {
    let trackingProvider: TrackingType

    private let libraryRepository: LibraryRepositoryType
    private let learningCardOptionsRepository: LearningCardOptionsRepositoryType
    private let learningCardStack: PointableStack<LearningCardDeeplink>
    private let userStage: UserStage?

    // Workaround:
    // Tracking events for opening and closing single sections (trackSectionOpened, trackSectionClosed) are fired via a callback
    // that hooks into WebViewBridge, means: state of open and closed sections is reported via js callback
    // That leads to timing problems with (trackOpenAllSections and trackCloseAllSections)
    // Tracking for these events happens directly after the user tapps the toolbar button (no js callbacks)
    // Problem is:
    // When tracking open/close events for all sections at once, we do not want that the single callbacks
    // for each distinct section fire separate tracking events. But the js callbacks always arrive delayed
    // and out of queue. So simply disabling them for a brief moment does not work.
    // This leads to the solution with these two booleans. What this does essentially is:
    // * In case all sections have been collapsed at once -> ignore any trackSectionClosed() until any other event arrives
    // * In case all sections have been opened at once -> ignore any trackSectionOpened() until any other event arrives
    // This (although still laborious) seems to be the simplest approach to make this work for now
    private var shouldIgnoreOpenSectionTracking = false
    private var shouldIgnoreCollapseSectionTracking = false

    private var findInPageSessionID: String?

    init(trackingProvider: TrackingType,
         libraryRepository: LibraryRepositoryType = resolve(),
         learningCardOptionsRepository: LearningCardOptionsRepositoryType,
         learningCardStack: PointableStack<LearningCardDeeplink>,
         userStage: UserStage?
    ) {
        self.trackingProvider = trackingProvider
        self.libraryRepository = libraryRepository
        self.learningCardOptionsRepository = learningCardOptionsRepository
        self.learningCardStack = learningCardStack
        self.userStage = userStage
    }
}

extension LearningCardTracker {

    func trackLearningRadar(isEnabled: Bool) {
        unignoreSectionOpenAndCollapseTracking()
        withArticleID { [weak self] id in
            if isEnabled {
                self?.trackingProvider.track(.articleLearningRadarToggledOn(articleID: id.value))
            } else {
                self?.trackingProvider.track(.articleLearningRadarToggledOff(articleID: id.value))
            }
        }
    }

    func trackInArticleSearchOpened() {
        renewFindInPageSessionID()
        unignoreSectionOpenAndCollapseTracking()
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.articleInPageSearchOpened(articleID: id.value))
        }
    }

    func trackArticleFindInPageEdited(currentInput: String?, totalMatches: Int, currentMatch: Int) {
        let currentInput = currentInput ?? ""
        guard !currentInput.isEmpty else { return }

        guard let findInPageSessionID = findInPageSessionID else {
            assertionFailure("findInPageSessionID must not be nil")
            return
        }

        withArticleIDAndSearchSessionID { [weak self] articleID, searchSessionID in
            self?.trackingProvider.track(.articleFindInPageEdited(
                articleID: articleID.value,
                searchSessionID: searchSessionID,
                findInPageSessionID: findInPageSessionID,
                currentInput: currentInput,
                totalMatches: totalMatches,
                currentMatch: currentMatch))
        }
    }

    func trackPresentShareSheet() {
        unignoreSectionOpenAndCollapseTracking()
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.articleShareOpened(articleID: id.value))
        }
    }

    func trackShareSent() {
        unignoreSectionOpenAndCollapseTracking()
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.articleShareSent(articleID: id.value))
        }
    }

    func trackIsLearned(isEnabled: Bool) {
        unignoreSectionOpenAndCollapseTracking()
        withArticleID { [weak self] id in
            let locatedOn = "article"
            if isEnabled {
                self?.trackingProvider.track(.articleLearnedToggledOn(articleID: id.value, locatedOn: locatedOn))
            } else {
                self?.trackingProvider.track(.articleLearnedToggledOff(articleID: id.value, locatedOn: locatedOn))
            }
        }
    }

    func trackHighlighting(isEnabled: Bool) {
        unignoreSectionOpenAndCollapseTracking()
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.articleHighlightingToggled(articleID: id.value, isEnabled: isEnabled))
        }
    }

    func trackHighYield(isEnabled: Bool) {
        unignoreSectionOpenAndCollapseTracking()
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.articleHighYieldToggled(articleID: id.value, isEnabled: isEnabled))
        }
    }

    func trackArticleFavorite(isFavorite: Bool) {
        unignoreSectionOpenAndCollapseTracking()
        withArticleID { [weak self] id in
            if isFavorite {
                self?.trackingProvider.track(.articleFavoriteSet(articleID: id.value))
            } else {
                self?.trackingProvider.track(.articleFavoriteRemoved(articleID: id.value))
            }
        }
    }

    func trackArticleSelected() {
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.articleSelected(articleID: id.value, referrer: .article))
        }
    }

    func trackStartReading(for identifier: LearningCardIdentifier) {
        unignoreSectionOpenAndCollapseTracking()
        let options = learningCardOptionsRepository.learningCardOptions()
        withArticleIDAndTitle(for: identifier) { [weak self] id, title in
            self?.trackingProvider.track(.articleOpened(articleID: id.value, title: title, options: options))
        }
    }

    func trackEndReading(for identifier: LearningCardIdentifier, with reading: LearningCardReading?) {
        unignoreSectionOpenAndCollapseTracking()
        guard let reading = reading else { return }
        withArticleIDAndTitle { [weak self] id, title in
            let event = Tracker.Event.Article.articleClosed(articleID: id.value, title: title, viewingDuration: reading.timeSpent)
            self?.trackingProvider.track(event)
        }
    }

    func trackTooltipOpen(tooltipType: String?) {
        withArticleIDAndTitle { [weak self] _, title in
            let event = Tracker.Event.Article.tooltipOpened(articleTitle: title, tooltipType: tooltipType)
            self?.trackingProvider.track(event)
        }
    }
}

extension LearningCardTracker {

    func trackSectionOpened(sectionID: String) {
        guard shouldIgnoreOpenSectionTracking == false else { return }
        unignoreSectionOpenAndCollapseTracking()
        withArticleIDAndTitle { [weak self] id, title in
            self?.trackingProvider.track(.articleExpandSection(articleID: id.value, title: title, sectionID: sectionID))
        }
    }

    func trackSectionClosed(sectionID: String) {
        guard shouldIgnoreCollapseSectionTracking == false else { return }
        unignoreSectionOpenAndCollapseTracking()
        withArticleIDAndTitle { [weak self] id, title in
            self?.trackingProvider.track(.articleCollapseSection(articleID: id.value, title: title, sectionID: sectionID))
        }
    }

    func trackOpenAllSections() {
        shouldIgnoreOpenSectionTracking = true
        shouldIgnoreCollapseSectionTracking = false
        withArticleIDAndTitle { [weak self] id, title in
            self?.trackingProvider.track(.articleExpandAllSections(articleID: id.value, title: title))
        }
    }

    func trackCloseAllSections() {
        shouldIgnoreOpenSectionTracking = false
        shouldIgnoreCollapseSectionTracking = true
        withArticleIDAndTitle { [weak self] id, title in
            self?.trackingProvider.track(.articleCollapseAllSections(articleID: id.value, title: title))
        }
    }

    func trackArticleAnchorIdInvalid(articleID: String, id: String) {
        trackingProvider.track(.articleAnchorIdInvalid(articleID: articleID, id: id))
    }

    func trackArticleParticleIdInvalid(articleID: String, id: String) {
        trackingProvider.track(.articleParticleIdInvalid(articleID: articleID, id: id))
    }

    func trackArticleDosageOpened(dosageID: DosageIdentifier, source: DataSource) {
        withArticleID { id in
            self.trackingProvider.track(.pharmaDosageShown(articleID: id.value, dosageID: dosageID.value, source: source))
        }
    }

    func trackArticleDosageOpenFailed(dosageID: DosageIdentifier, error: Error) {
        withArticleID { id in
            self.trackingProvider.track(.articleDosageOpenFailed(articleID: id.value, dosageID: dosageID.value, error: String(describing: error)))
        }
    }

    func trackArticleDosageLinkClicked(dosageID: DosageIdentifier, ambossSubstanceLink: AmbossSubstanceLink) {
        withArticleID { id in
            guard let dosage = Int(dosageID.value),
                  let deeplink = ambossSubstanceLink.deeplink,
                  let substance = Int(ambossSubstanceLink.id) else { return }

            switch deeplink {
            case .pharmaCard(let pharmaCardDeeplink):
                guard let substance = Int(ambossSubstanceLink.id),
                      let drugID = pharmaCardDeeplink.drug,
                      let drug = Int(drugID.value) else { return }

                self.trackingProvider.track(
                    .articleDosageLinkClicked(articleID: id.value,
                                              dosageID: dosage,
                                              substanceID: substance,
                                              drugID: drug))
            case .monograph:
                self.trackingProvider.track(
                    .articleDosageLinkClicked(articleID: id.value,
                                              dosageID: dosage,
                                              substanceID: substance,
                                              drugID: nil))
            }

        }
    }

    // This is part of an experiment that shows the monographs screen directly to US clinicians
    // (instead of the the phrasionary + pharma learning card combination)
    // when they tap on a medication name.
    // It's basically the same as tapping a pharma pill but without the popup before presenting the monograph
    // See here for more info: https://miamed.atlassian.net/browse/PHEX-1351
    func trackMonographExperimentLink(for identifier: LearningCardIdentifier,
                                      monographID: MonographIdentifier,
                                      snippetID: SnippetIdentifier) {
        withArticleIDAndTitle(for: identifier) { [weak self] articleID, _ in
            self?.trackingProvider.track(
                .pharmaAnchorLinkClicked(articleXID: articleID.value,
                                         monographID: monographID.value,
                                         snippetID: snippetID.value))
        }
    }
}

extension LearningCardTracker {

    func trackNavigatedForward() {
        self.trackingProvider.track(.articleNavigatedForward)
    }

    func trackNavigatedBackward() {
        self.trackingProvider.track(.articleNavigatedBackward)
    }
}

extension LearningCardTracker: GalleryAnalyticsTrackingProviderType {

    func trackShowImageExplanations(imageID: ImageResourceIdentifier) {
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.imageMediaviewerToggleImageExplanations(articleId: id.value, imageId: imageID.value, toggleState: .toggleOn))
        }
    }

    func trackHideImageExplanations(imageID: ImageResourceIdentifier) {
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.imageMediaviewerToggleImageExplanations(articleId: id.value, imageId: imageID.value, toggleState: .toggleOff))
        }
    }

    func trackShowImageOverlay(imageID: ImageResourceIdentifier) {
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.imageMediaviewerToggleOverlay(articleId: id.value, imageId: imageID.value, toggleState: .toggleOn))
        }
    }

    func trackHideImageOverlay(imageID: ImageResourceIdentifier) {
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.imageMediaviewerToggleOverlay(articleId: id.value, imageId: imageID.value, toggleState: .toggleOff))
        }
    }

    func trackShowSmartZoom(imageID: ImageResourceIdentifier) {
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.imageMediaviewerToggleSmartzoom(articleId: id.value, imageId: imageID.value, toggleState: .toggleOn))
        }
    }

    func trackCloseSmartZoom(imageID: ImageResourceIdentifier) {
        withArticleID { [weak self] id in
            self?.trackingProvider.track(.imageMediaviewerToggleSmartzoom(articleId: id.value, imageId: imageID.value, toggleState: .toggleOff))
        }
    }

    func trackShowImageMediaviewer(imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?) {
        withArticleID { [weak self] id in
            self?.trackShowImageMediaviewer(articleId: id.value, imageID: imageID, title: title, externalAdditionType: externalAdditionType)
        }
    }

    func trackCloseImageMediaviewer(imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?) {
        withArticleID { [weak self] id in
            self?.trackCloseImageMediaviewer(articleId: id.value, imageID: imageID, title: title, externalAdditionType: externalAdditionType)
        }
    }

    func trackShowImageMediaviewer(articleId: String?, imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?) {
        var media: Tracker.Event.Media.Media?
        var externalAddition: Tracker.Event.Media.ExternalAddition?
        if let imageID = imageID {
            media = Tracker.Event.Media.Media(eid: imageID.value, title: title)
        }
        if let externalAdditionType = externalAdditionType {
            externalAddition = Tracker.Event.Media.ExternalAddition(type: externalAdditionType)
        }
        trackingProvider.track(.imageMediaviewerWasShown(articleId: articleId, imageId: imageID?.value, media: media, externalAddition: externalAddition, referrer: Tracker.Event.Media.Referrer(articleEid: articleId ?? "")))
    }

    func trackCloseImageMediaviewer(articleId: String?, imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?) {
        var media: Tracker.Event.Media.Media?
        var externalAddition: Tracker.Event.Media.ExternalAddition?
        if let imageID = imageID {
            media = Tracker.Event.Media.Media(eid: imageID.value, title: title)
        }
        if let externalAdditionType = externalAdditionType {
            externalAddition = Tracker.Event.Media.ExternalAddition(type: externalAdditionType)
        }
        trackingProvider.track(.imageMediaviewerWasHidden(articleId: articleId, imageId: imageID?.value, media: media, externalAddition: externalAddition, referrer: Tracker.Event.Media.Referrer(articleEid: articleId ?? "")))
    }

    func trackShowVideoMediaviewer(url: URL) {
        withArticleID { [weak self] id in
            self?.trackShowVideoMediaviewer(articleId: id.value, url: url)
        }
    }

    func trackShowVideoMediaviewer(articleId: String?, url: URL) {
        trackingProvider.track(.videoMediaviewerWasShown(articleId: articleId, mediaUrl: url.absoluteString, referrer: Tracker.Event.Media.Referrer(articleEid: articleId ?? "")))
    }

    func trackNoAccessBuyLicense() {
        trackingProvider.track(.noAccessBuyLicense)
    }
}

extension LearningCardTracker {

    func trackOptionsMenuOpened() {
        guard let userStage = userStage else { return }
        withArticleID { [weak self] articleID in
            var stage: Tracker.Event.Article.Stage
            switch userStage {
            case .clinic: stage = .clinic
            case .preclinic: stage = .preclinic
            case .physician: stage = .physician
            }
            self?.trackingProvider.track(.articleOptionsMenuOpened(articleID: articleID.value, userStage: stage))
        }
    }
}

extension LearningCardTracker {

    func renewFindInPageSessionID() {
        findInPageSessionID = NSUUID().uuidString
    }
}

private extension LearningCardTracker {

    func withArticleIDAndTitle(for identifier: LearningCardIdentifier, callback: (LearningCardIdentifier, String) -> Void) {
        guard let learningCardMetadata = try? libraryRepository.library.learningCardMetaItem(for: identifier) else { return }
        let title = learningCardMetadata.title
        callback(identifier, title)
    }

    func withArticleIDAndSearchSessionID(callback: (LearningCardIdentifier, String?) -> Void) {
        guard
            let currentItem = learningCardStack.currentItem,
            let metadata = try? libraryRepository.library.learningCardMetaItem(for: currentItem.learningCard)
        else { return }

        let articleID = metadata.learningCardIdentifier
        callback(articleID, currentItem.searchSessionID)
    }

    func withArticleIDAndTitle(callback: (LearningCardIdentifier, String) -> Void) {
        guard
            let currentItem = learningCardStack.currentItem,
            let metadata = try? libraryRepository.library.learningCardMetaItem(for: currentItem.learningCard)
        else { return }

        let articleID = metadata.learningCardIdentifier
        let title = metadata.title
        callback(articleID, title)
    }

    func withArticleID(callback: (LearningCardIdentifier) -> Void) {
        guard
            let currentItem = learningCardStack.currentItem,
            let metadata = try? libraryRepository.library.learningCardMetaItem(for: currentItem.learningCard)
        else { return }

        let articleID = metadata.learningCardIdentifier
        callback(articleID)
    }

    func unignoreSectionOpenAndCollapseTracking() {
        shouldIgnoreOpenSectionTracking = false
        shouldIgnoreCollapseSectionTracking = false
    }
}
