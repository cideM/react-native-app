//
//  Theme.swift
//  Common
//
//  Created by CSH on 04.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

/// A Theme describes the use cases / semantic meaning of a color in a certain context.
public protocol Theme {
    var tintColor: UIColor { get }
    var barTintColor: UIColor { get }

    var backgroundColor: UIColor { get }
    var textBackgroundColor: UIColor { get }
    var backgroundTransparentColor: UIColor { get }

    var searchSuggestionsListTextColor: UIColor { get }
    var searchSuggestionsListAccessoryColor: UIColor { get }
    var textColor: UIColor { get }
    var secondaryTextColor: UIColor { get }
    var headerTextAttributes: [NSAttributedString.Key: Any] { get }
    var footerViewTextAttributes: [NSAttributedString.Key: Any] { get }

    var textFieldSubviewColor: UIColor { get }
    var textFieldBackgroundColor: UIColor { get }
    var bigTextFieldTextColor: UIColor { get }

    var primaryButtonBackgroundColor: UIColor { get }
    var primaryButtonBorderColor: UIColor { get }
    var primaryButtonTextColor: UIColor { get }

    var disabledPrimaryButtonBackgroundColor: UIColor { get }
    var disabledPrimaryButtonBorderColor: UIColor { get }
    var disabledPrimaryButtonTextColor: UIColor { get }

    var linkButtonBackgroundColor: UIColor { get }
    var linkButtonBorderColor: UIColor { get }
    var linkButtonTextColor: UIColor { get }
    var linkWithBordersButtonBorderColor: UIColor { get }
    var linkExternalButtonTextColor: UIColor { get }

    var disabledLinkButtonBackgroundColor: UIColor { get }
    var disabledLinkButtonBorderColor: UIColor { get }
    var disabledLinkButtonTextColor: UIColor { get }

    var defaultCornerRadius: CGFloat { get }
    var defaultShadowColor: UIColor { get }
    var defaultShadowRadius: CGFloat { get }
    var defaultShadowOpacity: Float { get }
    var defaultShadowOffset: CGSize { get }

    var welcomeButtonBackgroundColor: UIColor { get }
    var welcomeButtonBorderColor: UIColor { get }
    var welcomeButtonTextColor: UIColor { get }

    var welcomeInvertedButtonBackgroundColor: UIColor { get }
    var welcomeInvertedButtonBorderColor: UIColor { get }
    var welcomeInvertedButtonTextColor: UIColor { get }

    var navigationBarBackgroundColor: UIColor { get }
    var navigationBarItemColor: UIColor { get }
    var navigationBarLargeTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var navigationBarTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var popoverNavigationBarBackgroundColor: UIColor { get }

    var popoverTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var dosagePopoverContentTextAttributes: [NSAttributedString.Key: Any] { get }
    var popoverCloseButtonTintColor: UIColor { get }

    var titleTextAttributes: [NSAttributedString.Key: Any] { get }

    var tabBarSelectedItemTextAttributes: [NSAttributedString.Key: Any] { get }
    var tabBarUnselectedItemTextAttributes: [NSAttributedString.Key: Any] { get }
    var tabBarSelectedItemIconTintColor: UIColor { get }

    var textFieldTextAttributes: [NSAttributedString.Key: Any] { get }

    var textViewLinkTextAttributes: [NSAttributedString.Key: Any] { get }

    var welcomeViewTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var welcomeViewSubtitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var selectableCellTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var selectableCellDescriptionTextAttributes: [NSAttributedString.Key: Any] { get }
    var selectableCellSeperatorColor: UIColor { get }

    var informationLabelTextAttributes: [NSAttributedString.Key: Any] { get }
    var informationLabelTextAttributesRed: [NSAttributedString.Key: Any] { get }

    var settingsDestructiveButtonTextAttributes: [NSAttributedString.Key: Any] { get }
    var emailTextViewBoldTextAttributes: [NSAttributedString.Key: Any] { get }

    var libraryViewTitleLabelTextAttributes: [NSAttributedString.Key: Any] { get }
    var libraryViewChildCountLabelTextAttributes: [NSAttributedString.Key: Any] { get }

    var pieChartBackgroundColor: UIColor { get }

    var dashboardModeButtonBackgroundColor: UIColor { get }
    var dashboardModeButtonTextColor: UIColor { get }
    var dashboardUserStageButtonTextAttributes: [NSAttributedString.Key: Any] { get }

    var htmlDefaultFontName: String { get }
    var htmlDefaultFontSource: URL { get }

    var htmlHeaderFontName: String { get }
    var htmlHeaderFontSource: URL { get }

    var htmlSubHeaderFontName: String { get }
    var htmlSubHeaderFontSource: URL { get }

    var snippetTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var snippetSynonymTextAttributes: [NSAttributedString.Key: Any] { get }
    var snippetEtymologyTextAttributes: [NSAttributedString.Key: Any] { get }
    var snippetDescriptionTextAttributes: [NSAttributedString.Key: Any] { get }
    var snippetTargetButtonTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var snippetTargetButtonImageTint: UIColor { get }
    var snippetTargetButtonChevronColor: UIColor { get }

    var dosageTargetButtonTitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var galleryImageTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var galleryImageDescriptionTextAttributes: [NSAttributedString.Key: Any] { get }

    var galleryImageCopyrightTextAttributes: [NSAttributedString.Key: Any] { get }
    var galleryImageCopyrightLinkTextAttributes: [NSAttributedString.Key: Any] { get }
    var galleryButtonTintColor: UIColor { get }
    var galleryHiddenNavigationBackgroundColor: UIColor { get }
    var galleryBackgroundColor: UIColor { get }
    var galleryPanelCollapsedBackgroundColor: UIColor { get }

    var segmentedControlBackgroundColor: UIColor { get }
    var segmentedControlImageColor: UIColor { get }

    var miniMapParentTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var miniMapChildTitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var extensionCellButtonTextAttributes: [NSAttributedString.Key: Any] { get }
    var extensionCellTitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var searchTextFieldTextAttributes: [NSAttributedString.Key: Any] { get }
    var searchTextFieldPlaceholderTextAttributes: [NSAttributedString.Key: Any] { get }
    var searchTextFieldIconTintColor: UIColor { get }
    var searchTextFieldTintColor: UIColor { get }

    var searchHistoryTableViewCellTextAttributes: [NSAttributedString.Key: Any] { get }
    var searchHistoryTableViewCellImageTintColor: UIColor { get }

    var newsfeedEntryTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var newsfeedPublishTextAttributes: [NSAttributedString.Key: Any] { get }
    var newsfeedLinkTextAttributes: [NSAttributedString.Key: Any] { get }
    var newsfeedContentTextAttributes: [NSAttributedString.Key: Any] { get }
    var newsfeedContentFontSize: CGFloat { get }

    var tableHeaderBorderColor: UIColor { get }

    var initializationScreenTextColor: UIColor { get }

    var quickDefineSnippetShadowColor: UIColor { get }

    var cardPresentationDimmingViewBackgroundColor: UIColor { get }

    var popoverBackgroundViewColor: UIColor { get }

    var searchToolbarShadowColor: UIColor { get }

    var bigButtonNormalFont: UIFont { get }
    var bigButtonNormalFontColor: UIColor { get }
    var bigButtonNormalBackgroundColor: UIColor { get }
    var bigButtonNormalBorderColor: UIColor { get }

    var bigButtonDisabledBackgroundColor: UIColor { get }
    var bigButtonDisabledBorderColor: UIColor { get }
    var bigButtonDisabledFontColor: UIColor { get }

    var searchResultTableViewBackgroundColor: UIColor { get }
    var searchResultTableViewTagButtonOutlineColor: UIColor { get }

    var searchResultTableViewHeaderBackgroundColor: UIColor { get }
    var searchResultTableViewHeaderIconTintColor: UIColor { get }
    var searchResultTableViewHeaderTitleAttributes: [NSAttributedString.Key: Any] { get }
    var searchResultTableViewHeaderButtonTitleAttributes: [NSAttributedString.Key: Any] { get }

    var searchResultTableViewCellNormalTitleAttributes: [NSAttributedString.Key: Any] { get }
    var searchResultTableViewCellBoldTitleAttributes: [NSAttributedString.Key: Any] { get }
    var searchResultTableViewCellItalicTitleAttributes: [NSAttributedString.Key: Any] { get }

    var searchResultTableViewCellNormalSubtitleAttributes: [NSAttributedString.Key: Any] { get }
    var searchResultTableViewCellBoldSubtitleAttributes: [NSAttributedString.Key: Any] { get }
    var searchResultTableViewCellItalicSubtitleAttributes: [NSAttributedString.Key: Any] { get }

    var searchResultTableViewCellNormalBodyAttributes: [NSAttributedString.Key: Any] { get }
    var searchResultTableViewCellBoldBodyAttributes: [NSAttributedString.Key: Any] { get }
    var searchResultTableViewCellItalicBodyAttributes: [NSAttributedString.Key: Any] { get }

    var searchResultTableViewCellNormalTitleNonClickableAttributes: [NSAttributedString.Key: Any] { get }
    var phrasionarySearchResultSecondaryTargetNormalTitleAttributes: [NSAttributedString.Key: Any] { get }
    var phrasionarySearchResultSecondaryTargetBoldTitleAttributes: [NSAttributedString.Key: Any] { get }
    var phrasionarySearchResultSecondaryTargetItalicTitleAttributes: [NSAttributedString.Key: Any] { get }

    var searchSuggestionItemBoldTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var searchSuggestionItemNormalTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var searchSuggestionItemItalicTitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var substanceSectionTableViewHeaderBackgroundColor: UIColor { get }
    var substanceSectionTableViewHeaderExpandedBackgroundColor: UIColor { get }

    var activeIngredientTitleLabelTextAttributes: [NSAttributedString.Key: Any] { get }

    var agentPrescribingInformationSectionLabelTextAttributes: [NSAttributedString.Key: Any] { get }
    var agentPrescribingInformationSectionValueLabelTextAttributes: [NSAttributedString.Key: Any] { get }
    var agentPrescribingInformationLabelTextAttributes: [NSAttributedString.Key: Any] { get }
    var agentPrescribingInformationSubtitleLabelTextAttributes: [NSAttributedString.Key: Any] { get }
    var agentPatientPackageLabelTextAttributes: [NSAttributedString.Key: Any] { get }
    var agentPatientPackageSubtitleLabelTextAttributes: [NSAttributedString.Key: Any] { get }

    var patientPackageButtonTintColor: UIColor { get }

    var drugListTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var drugListItemTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var drugListItemVendorTextAttributes: [NSAttributedString.Key: Any] { get }
    var drugListItemATCTextAttributes: [NSAttributedString.Key: Any] { get }
    var drugListItemApplicationFormsTextAttributes: [NSAttributedString.Key: Any] { get }
    var drugListItemPricesAndPackageSizesTextAttributes: [NSAttributedString.Key: Any] { get }

    var settingsSubtitleLabelTextAttributes: [NSAttributedString.Key: Any] { get }
    var settingsLibraryAndPharmaTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var settingsLibraryAndPharmaSubtitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var settingsLibraryAndPharmaDeleteDisclaimerTextAttributes: [NSAttributedString.Key: Any] { get }
    var settingsLibraryAndPharmaNormalTextAttributes: [NSAttributedString.Key: Any] { get }

    var userStageCellTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var userStageCellDescriptionTextAttributes: [NSAttributedString.Key: Any] { get }
    var userStageFooterTextAttributes: [NSAttributedString.Key: Any] { get }

    var loginSSOHintTextAttributes: [NSAttributedString.Key: Any] { get }

    var signUpTitleLabelTextAttributes: [NSAttributedString.Key: Any] { get }
    var signUpAlreadyRegisteredLabelTextAttributes: [NSAttributedString.Key: Any] { get }

    var usagePurposeCellTitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var offlineModeLabelBackgroundColor: UIColor { get }
    var offlineModeFirstTextAttributes: [NSAttributedString.Key: Any] { get }
    var offlineModeSecondTextAttributes: [NSAttributedString.Key: Any] { get }

    var searchNoResultsViewTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var searchNoResultsViewSubtitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var searchTagLabelTextAttributes: [NSAttributedString.Key: Any] { get }

    var searchFiltersTagNormalBorderColor: UIColor { get }
    var searchFiltersTagNormalBackgroundColor: UIColor { get }
    var searchFiltersTagNormalTextAttributes: [NSAttributedString.Key: Any] { get }
    var searchFiltersTagSelectedBorderColor: UIColor { get }
    var searchFiltersTagSelectedBackgroundColor: UIColor { get }
    var searchFiltersTagSelectedTextAttributes: [NSAttributedString.Key: Any] { get }

    var searchMediaViewTypeTextAttributes: [NSAttributedString.Key: Any] { get }
    var searchMediaViewTypeImageTintColor: UIColor { get }
    var searchMediaviewImageBackgroundColor: UIColor { get }
    var searchMediaViewTypeImageBorderColor: UIColor { get }
    var searchMediaViewTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var searchMediaViewMoreTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var searchMediaViewMoreBackgroundColor: UIColor { get }
    var searchMediaViewMoreBorderColor: UIColor { get }
    var mediaSearchViewBackgroundGradientColors: [CGColor] { get }

    var showAllButtonTitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var recentsListEmptyStateTextAttributes: [NSAttributedString.Key: Any] { get }
    var dashboardSectionSeparatorColor: UIColor { get }
    var iAPBannerSeparatorColor: UIColor { get }

    var dashboardSectionTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var dashboardSectionHeaderButtonTitleAttributes: [NSAttributedString.Key: Any] { get }

    var dashboardClinicalToolsIconColor: UIColor { get }
    var dashboardClinicalToolsTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var dashboardClinicalToolsSubtitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var dashboardClinicalToolsCountTextAttributes: [NSAttributedString.Key: Any] { get }

    var contentListSearchBarBackgroundColor: UIColor { get }
    var contentListSearchFieldBackgroundColor: UIColor { get }
    var contentListSearchIconTintColor: UIColor { get }
    var contentListSearchFieldPlaceholderAttributes: [NSAttributedString.Key: Any] { get }
    var contentListMessageTitleAttributes: [NSAttributedString.Key: Any] { get }
    var contentListMessageSubtitleAttributes: [NSAttributedString.Key: Any] { get }
    var contentListMessageButtonTitleAttributes: [NSAttributedString.Key: Any] { get }

    var clinicalReferenceMainIconColor: UIColor { get }
    var clinicalReferenceButtonImageColor: UIColor { get }
    var clinicalReferenceItemTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var clinicalReferenceButtonBackgroundColor: UIColor { get }
    var clinicalReferenceButtonTitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var clinicalToolButtonImageColor: UIColor { get }
    var clinicalToolButtonBackgroundColor: UIColor { get }
    var clinicalToolButtonTitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var discoverAmbossCloseButtonColor: UIColor { get }
    var discoverAmbossSectionTitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var iAPBannerViewTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var iAPBannerViewSubtitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var iAPStoreViewTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var iAPStoreViewSubtitleTextAttributes: [NSAttributedString.Key: Any] { get }

    var iAPStoreViewInfoTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var iAPStoreViewInfoSubtitleTextAttributes: [NSAttributedString.Key: Any] { get }
    var iAPStoreViewInfoSubtitleCenteredTextAttributes: [NSAttributedString.Key: Any] { get }

    var iAPStoreIconTintColor: UIColor { get }

    var videoModalCloseButtonColor: UIColor { get }

    var feedbackIntentionsMenuChevronColor: UIColor { get }

    var learningCardOptionsButtonImageTint: UIColor { get }
    var learningCardOptionsDividerColor: UIColor { get }
    var learningCardOptionsButtonTitleAttributes: [NSAttributedString.Key: Any] { get }
    var learningCardOptionsSwitchTitleAttributes: [NSAttributedString.Key: Any] { get }
    var learningCardOptionsSwitchSubtitleAttributes: [NSAttributedString.Key: Any] { get }
    var learningCardOptionsSubheadingAttributes: [NSAttributedString.Key: Any] { get }
}
