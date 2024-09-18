//
//  StorageKey.swift
//  Knowledge
//
//  Created by CSH on 24.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

enum StorageKey: CustomStringConvertible {
    case libraryFolderName
    case preparedLibraryFolderName
    case tagSynchronizerEndCursor
    case tagSynchronizerLastUploadDate
    case extensionsSynchronizerEndCursor
    case userStage
    case studyObjective
    case currentFontScale
    case requiredMustUpdate
    case isLibraryBackgroundUpdatesEnabled
    case didPresentAutoUpdateAlert
    case libraryUpdaterState
    case lastKnownRecommendedUpdateVersion
    case extensions
    case sharedExtensions
    case userSharedExtensionsEndCursor(UserIdentifier)
    case extensionNote(LearningCardSectionIdentifier)
    case sharedExtensionNote(LearningCardSectionIdentifier, UserIdentifier)
    case taggings
    case deviceIdentifier
    case authorization
    case isHighlightingModeEnabled
    case isHighYieldModeEnabled
    case isPhysikumFocusModeEnabled
    case isLearningRadarEnabled
    case sectionFeedbackItems
    case keepScreenOn
    case usersWhoShareExtensionsWithCurrentUser
    case accesses
    case accessesLastSynchronizationDate
    case qbankAnswers
    case qbankAnswersEndCursor
    case searchHistory
    case appLaunchCount
    case articleViewCount
    case firstAppLaunchDate
    case appReviewPromptLastDisplayDate
    case deprecationStatus
    case learningCardReadings
    case hasConfirmedHealthCareProfession
    case featureFlags
    case firstLoginWasTracked
    case firstContentViewWasTracked
    case isPharmaBackgroundUpdatesEnabled
    case pharmaResultWasDisplayedCount
    case pharmaDialogWasDisplayedDate
    case shouldShowPharmaOfflineDialog
    case searchUsageCount
    case addingVoiceShortcutForSearchWasOffered
    case hasClosedDiscoverAmbossView
    case initialConsentDialogWasShown
    case didPresentStoreAfterSignup
    case galleryPillPosition
    case iapCountryCodeWasUpdated
    case mostRecentUserTriggeredAppLaunchDate // its not user triggered in case its a background fetch
    case brazeInitialIdentificationCompletedKey
    case lastContentCardDismissDates
    case userGaveAdjustConsent
    case currentUserInterfaceStyle
    case shouldUpdateTerms

    var description: String {
        switch self {
        case .currentUserInterfaceStyle: return "currentUserInterfaceStyle"
        case .libraryFolderName: return "libraryFolderName"
        case .preparedLibraryFolderName: return "preparedLibraryFolderName"
        case .tagSynchronizerEndCursor: return "tagSynchronizerEndCursor"
        case .tagSynchronizerLastUploadDate: return "tagSynchronizerLastUploadDate"
        case .extensionsSynchronizerEndCursor: return "extensionsSynchronizerEndCursor"
        case .userStage: return "userStage"
        case .studyObjective: return "studyObjective"
        case .currentFontScale: return "currentFontScale"
        case .requiredMustUpdate: return "requiredMustUpdate"
        case .isLibraryBackgroundUpdatesEnabled: return "isLibraryBackgroundUpdatesEnabled"
        case .didPresentAutoUpdateAlert: return "didPresentAutoUpdateAlert"
        case .libraryUpdaterState: return "libraryUpdaterState"
        case .lastKnownRecommendedUpdateVersion: return "lastKnownRecommendedUpdateVersion"
        case .extensions: return "extensions"
        case .sharedExtensions: return "sharedExtensions"
        case .extensionNote(let section): return "extensions_\(section.value)"
        case .sharedExtensionNote(let section, let userIdentifier): return "shared_extensions_\(section.value)_\(userIdentifier.value)"
        case .userSharedExtensionsEndCursor(let userIdentifier): return "shared_extensions_user_end_cursor_\(userIdentifier.value)"
        case .taggings: return "taggings"
        case .deviceIdentifier: return "deviceIdentifier"
        case .authorization: return "authorization"
        case .isHighlightingModeEnabled: return "isHighlightingModeEnabled"
        case .isHighYieldModeEnabled: return "isHighYieldModeEnabled"
        case .isPhysikumFocusModeEnabled: return "isPhysikumFocusModeEnabled"
        case .isLearningRadarEnabled: return "isLearningRadarEnabled"
        case .sectionFeedbackItems: return "sectionFeedbackItems"
        case .keepScreenOn: return "keepScreenOn"
        case .usersWhoShareExtensionsWithCurrentUser: return "usersWhoShareExtensionsWithCurrentUser"
        case .accesses: return "accesses"
        case .accessesLastSynchronizationDate: return "accessesLastSynchronizationDate"
        case .qbankAnswers: return "qbankAnswers"
        case .qbankAnswersEndCursor: return "qbankAnswersEndCursor"
        case .searchHistory: return "searchHistory"
        case .appLaunchCount: return "appLaunchCount"
        case .articleViewCount: return "articleViewCount"
        case .firstAppLaunchDate: return "firstAppLaunchDate"
        case .appReviewPromptLastDisplayDate: return "appReviewPromptLastDisplayDate"
        case .deprecationStatus: return "deprecationStatus"
        case .learningCardReadings: return "learningCardReadings"
        case .hasConfirmedHealthCareProfession: return "hasConfirmedHealthCareProfession"
        case .featureFlags: return "featureFlags"
        case .firstLoginWasTracked: return "firstLoginWasTracked"
        case .firstContentViewWasTracked: return "firstContentViewWasTracked"
        case .isPharmaBackgroundUpdatesEnabled: return "isPharmaBackgroundUpdatesEnabled"
        case .pharmaResultWasDisplayedCount: return "pharmaResultWasDisplayedCount"
        case .pharmaDialogWasDisplayedDate: return "pharmaDialogWasDisplayedDate"
        case .shouldShowPharmaOfflineDialog: return "shouldShowPharmaOfflineDialog"
        case .searchUsageCount: return "searchUsageCount"
        case .addingVoiceShortcutForSearchWasOffered: return "addingVoiceShortcutForSearchWasOffered"
        case .hasClosedDiscoverAmbossView: return "hasClosedDiscoverAmbossView"
        case .initialConsentDialogWasShown: return "initialConsentDialogWasShown"
        case .didPresentStoreAfterSignup: return "didPresentStoreAfterSignup"
        case .galleryPillPosition: return "galleryPillPosition"
        case .iapCountryCodeWasUpdated: return "iapCountryCodeWasUpdated"
        case .mostRecentUserTriggeredAppLaunchDate: return "mostRecentUserTriggeredAppLaunchDate"
        case .brazeInitialIdentificationCompletedKey: return "brazeInitialIdentificationCompleted"
        case .lastContentCardDismissDates: return "lastContentCardDismissDates"
        case .userGaveAdjustConsent: return "userGaveAdjustConsent'"
        case .shouldUpdateTerms: return "shouldUpdateTerms"
        }
    }
}
