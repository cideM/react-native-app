//
//  LearningCardCoordinatorType.swift
//  Knowledge DE
//
//  Created by Vedran Burojevic on 01/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit

/// @mockable
protocol LearningCardCoordinatorType: Coordinator {

    ///  A function that navigates to a new `LearningCardDeeplink`.
    /// - Parameters:
    ///   - deeplink: A LearningCardDeeplink describing the navigation destination.
    ///   - snippetAllowed: Decides whether we can show a `Snippet` for a specific `deeplink` or not.
    ///   - shouldPopToRoot: Decides whether we should pop to root or not.
    func navigate(to deeplink: LearningCardDeeplink, snippetAllowed: Bool, shouldPopToRoot: Bool)
    func navigate(to pharmaCard: PharmaCardDeeplink)
    func navigate(to monograph: MonographDeeplink)
    func navigate(to externalAddition: ExternalAdditionIdentifier, tracker: GalleryAnalyticsTrackingProviderType)
    func navigate(to videoURL: URL, tracker: GalleryAnalyticsTrackingProviderType)
    func showTable(htmlDocument: HtmlDocument, tracker: LearningCardTracker)
    func showPopover(htmlDocument: HtmlDocument, tracker: LearningCardTracker, preferredContentSize: CGSize)
    func showPopover(for dosageIdentifier: DosageIdentifier, tracker: LearningCardTracker)
    func closePopover()
    func showLearningCardOptions(tracker: LearningCardTracker)
    func closeLearningCardOptions()
    func showImageGallery(_ galleryDeeplink: GalleryDeeplink, tracker: GalleryAnalyticsTrackingProviderType)
    func openURLExternally(_ url: URL)
    func openURLInternally(_ url: URL)
    func showUserFeedback(for deeplink: FeedbackDeeplink)
    /// A function that will present the snippet view.
    /// - Parameters:
    ///   - snippet: The snippet's data from which we'll set the view up.
    ///   - deeplink: We carry the `deeplink` in order to make use of it's `sourceAnchor`property  when we the snippet destination buttons inside the snippet view are created.
    func showSnippetView(with snippet: Snippet, for deeplink: Deeplink)
    func dismissFeedbackView()
    func showExtensionView(for learningCard: LearningCardIdentifier, and section: LearningCardSectionIdentifier)
    func dismissExtensionView()
    func showMiniMap(for learningCardIdentifier: LearningCardIdentifier, with currentModes: [String])
    func dismissMiniMapView()
    func share(_ learningCardShareItem: LearningCardShareItem, completion: @escaping (Bool) -> Void)
    func sendEmail(to emailAddress: String, onFailure: (EmailSendingError) -> Void)
    func showManageSharedExtensionsView()
    func showSearchView()
    func openQBankSessionCreation(for learningCard: LearningCardIdentifier)
    func goToStore(dismissModally: Bool, animated: Bool)
    func showError(title: String, message: String)
    func navigateToUserStageSettings()
}

extension LearningCardCoordinatorType {
    func navigate(to deeplink: LearningCardDeeplink, snippetAllowed: Bool, shouldPopToRoot: Bool = false) {
        navigate(to: deeplink, snippetAllowed: snippetAllowed, shouldPopToRoot: shouldPopToRoot)
    }
}
