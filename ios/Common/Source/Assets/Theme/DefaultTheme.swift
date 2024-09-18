//
//  DefaultTheme.swift
//  Common
//
//  Created by CSH on 04.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation
import UIKit
import DesignSystem

final class DefaultTheme: Theme {

    // MARK: MISC

    private var welcomeScreenParagraphAlignment: NSTextAlignment {
        UIDevice.current.userInterfaceIdiom == .pad ? .center : .left
    }

    let defaultCornerRadius: CGFloat = 8
    let newsfeedContentFontSize: CGFloat = 14

    let defaultShadowColor = Color.black.value.withAlphaComponent(0.07)
    let defaultShadowRadius: CGFloat = 3
    let defaultShadowOpacity: Float = 1
    let defaultShadowOffset = CGSize(width: 0, height: 2)

    // MARK: COLORS

    let bigButtonDisabledBorderColor = Color.black.value
    let bigButtonDisabledFontColor = Color.black.value
    let galleryHiddenNavigationBackgroundColor = Color.black.value

    let bigButtonNormalBackgroundColor = Color.blue.value
    let bigButtonNormalBorderColor = Color.blue.value

    let backgroundTransparentColor = Color.transparent.value

    let galleryButtonTintColor = Color.lightGray.value

    let bigButtonDisabledBackgroundColor = Color.white.value
    let bigButtonNormalFontColor = Color.white.value
    let textBackgroundColor = Color.white.value

    let disabledLinkButtonBorderColor = Color.black11.value
    let textColor = Color.black11.value

    let searchMediaViewMoreBorderColor = Color.black11.value.withAlphaComponent(0.1)

    let bigTextFieldTextColor = Color.brand32.value
    let segmentedControlBackgroundColor = Color.brand32.value
    let tabBarSelectedItemIconTintColor = Color.brand32.value
    let welcomeButtonTextColor = Color.brand32.value
    let welcomeInvertedButtonBackgroundColor = Color.brand32.value.withAlphaComponent(0.4)
    let disabledPrimaryButtonBackgroundColor = Color.brand32.value.withAlphaComponent(0.5)
    let disabledPrimaryButtonBorderColor = Color.brand32.value.withAlphaComponent(0.5)

    let disabledLinkButtonTextColor = Color.brand61.value

    let pieChartBackgroundColor = Color.brand66.value

    let dashboardModeButtonBackgroundColor = Color.brandLight3.value
    var dashboardModeButtonTextColor = Color.brand32.value

    let linkExternalButtonTextColor = Color.brandMain38.value
    let navigationBarBackgroundColor = Color.brandMain38.value
    let primaryButtonBackgroundColor = Color.brandMain38.value
    let primaryButtonBorderColor = Color.brandMain38.value
    let tintColor = Color.brandMain38.value

    let searchSuggestionsListTextColor = Color.gray15.value

    let dashboardClinicalToolsIconColor = Color.gray40.value
    let clinicalReferenceMainIconColor = Color.gray40.value
    let clinicalToolButtonImageColor = Color.gray40.value
    let discoverAmbossCloseButtonColor = Color.gray40.value
    let searchFiltersTagSelectedBackgroundColor = Color.gray40.value
    let searchResultTableViewHeaderIconTintColor = Color.gray40.value
    let videoModalCloseButtonColor = Color.gray40.value
    let contentListSearchIconTintColor = UIColor.iconSecondary

    let initializationScreenTextColor = Color.gray45.value
    let linkButtonTextColor = Color.textTertiary.value
    let linkWithBordersButtonBorderColor = Color.gray45.value
    let patientPackageButtonTintColor = Color.gray45.value
    let secondaryTextColor = Color.gray45.value

    let textFieldSubviewColor = Color.gray73.value

    let tableHeaderBorderColor = Color.gray80.value

    let backgroundColor = Color.gray95.value
    let galleryPanelCollapsedBackgroundColor = Color.gray95.value
    let learningCardOptionsDividerColor = Color.gray95.value
    let searchMediaViewMoreBackgroundColor = Color.gray95.value
    let contentListSearchFieldBackgroundColor = Color.gray95.value

    let searchMediaviewImageBackgroundColor = Color.gray96.value

    let learningCardOptionsButtonImageTint = Color.grayBlue.value
    let popoverCloseButtonTintColor = Color.grayBlue.value

    let searchTextFieldTintColor = Color.grayDark02.value

    let clinicalReferenceButtonImageColor = Color.grayLight01.value
    let feedbackIntentionsMenuChevronColor = Color.grayLight01.value
    let iAPBannerSeparatorColor = Color.grayLight01.value
    let iAPStoreIconTintColor = Color.grayLight01.value
    let searchHistoryTableViewCellImageTintColor = Color.grayLight01.value
    let searchMediaViewTypeImageTintColor = Color.grayLight01.value
    let searchSuggestionsListAccessoryColor = Color.grayLight01.value
    let snippetTargetButtonChevronColor = Color.grayLight01.value

    let dashboardSectionSeparatorColor = Color.grayLight02.value
    let offlineModeLabelBackgroundColor = Color.grayLight02.value
    let searchFiltersTagNormalBorderColor = Color.grayLight02.value
    let searchMediaViewTypeImageBorderColor = Color.grayLight02.value
    let searchResultTableViewTagButtonOutlineColor = Color.grayLight02.value
    let selectableCellSeperatorColor = Color.grayLight02.value

    let substanceSectionTableViewHeaderExpandedBackgroundColor = Color.grayLight04.value
    let popoverNavigationBarBackgroundColor = Color.grayLight04.value
    let searchResultTableViewBackgroundColor = Color.grayLight04.value
    let searchResultTableViewHeaderBackgroundColor = Color.grayLight04.value

    let searchTextFieldIconTintColor = Color.grayRegular.value

    let substanceSectionTableViewHeaderBackgroundColor = Color.white.value
    let disabledLinkButtonBackgroundColor = Color.white.value
    let galleryBackgroundColor = UIColor.backgroundSecondary
    let navigationBarItemColor = Color.white.value
    let primaryButtonTextColor = Color.white.value
    let segmentedControlImageColor = Color.white.value
    let textFieldBackgroundColor = Color.white.value
    let welcomeButtonBackgroundColor = Color.white.value
    let welcomeButtonBorderColor = Color.white.value
    let welcomeInvertedButtonBorderColor = Color.white.value
    let welcomeInvertedButtonTextColor = Color.white.value
    let contentListSearchBarBackgroundColor = Color.white.value

    let disabledPrimaryButtonTextColor = Color.white.value.withAlphaComponent(0.7)

    let quickDefineSnippetShadowColor = Color.black.value
    let searchToolbarShadowColor = Color.black.value

    let cardPresentationDimmingViewBackgroundColor = Color.black.value.withAlphaComponent(0.7)
    let popoverBackgroundViewColor = Color.white.value

    let linkButtonBackgroundColor = Color.transparent.value
    let linkButtonBorderColor = Color.transparent.value
    let searchFiltersTagNormalBackgroundColor = Color.transparent.value
    let searchFiltersTagSelectedBorderColor = Color.transparent.value

    let barTintColor = Color.white.value
    let clinicalReferenceButtonBackgroundColor = Color.white.value
    let clinicalToolButtonBackgroundColor = Color.white.value

    let mediaSearchViewBackgroundGradientColors: [CGColor] = [
        Color.blueGradient1.value.cgColor,
        Color.blueGradient2.value.cgColor
    ]

    // MARK: FONTS

    let htmlDefaultFontName = Font.regular.name
    let htmlDefaultFontSource = Font.regular.sourceUrl

    let htmlHeaderFontName = Font.bold.name
    let htmlHeaderFontSource = Font.bold.sourceUrl

    let htmlSubHeaderFontName = Font.medium.name
    let htmlSubHeaderFontSource = Font.medium.sourceUrl

    let bigButtonNormalFont = Font.black.font(withSize: 14)

    // MARK: PARAGRAPH STYLES

    lazy var searchResultMediaViewMoreTitleParagraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle(lineHeight: 16)
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        return paragraphStyle
    }()

    lazy var phrasionarySearchResultSecondaryTargetButtonTitleParagraphStyle: NSMutableParagraphStyle = { // swiftlint:disable:this identifier_name
        let paragraph = NSMutableParagraphStyle(lineHeight: 18)
        paragraph.lineHeightMultiple = 1.07
        paragraph.lineBreakMode = .byTruncatingTail
        paragraph.alignment = .left
        paragraph.hyphenationFactor = 1
        return paragraph
    }()

    private let leftAlignedLineHeight24: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle(lineHeight: 24, alignment: .left)
        style.lineBreakMode = .byTruncatingTail
        return style
    }()

    private let leftAlignedLineHeight26: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle(lineHeight: 26, alignment: .left)
        style.lineBreakMode = .byWordWrapping
        return style
    }()

    lazy var searchResultTableViewCellTitleParagraphStyle: NSMutableParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle(lineHeight: 24)
        paragraphStyle.lineHeightMultiple = 1.25
        paragraphStyle.lineBreakMode = .byTruncatingTail
        return paragraphStyle
    }()

    lazy var searchResultTableViewCellBodyParagraph: NSMutableParagraphStyle = {
        let paragraph = NSMutableParagraphStyle(lineHeight: 24)
        paragraph.lineHeightMultiple = 1.43
        paragraph.lineBreakMode = .byTruncatingTail
        paragraph.hyphenationFactor = 1
        return paragraph
    }()

    lazy var searchResultCollectionViewCellBodyParagraph: NSMutableParagraphStyle = {
        let paragraph = NSMutableParagraphStyle(lineHeight: 20)
        paragraph.lineBreakMode = .byTruncatingTail
        paragraph.hyphenationFactor = 1
        return paragraph
    }()

    // MARK: MISC ATTRIBUTES

    let settingsSubtitleLabelTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: Color.textSecondary.value,
        .font: Font.regular.font(withSize: 14)
    ]

    let newsfeedLinkTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.textAccent,
        .underlineColor: Color.transparent.value,
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]

    let textViewLinkTextAttributes: [NSAttributedString.Key: Any] = [
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]

    // MARK: FONT SIZES
    // MARK: 10
    // MISC

    // MARK: 11
    // MISC

    let tabBarSelectedItemTextAttributes: [NSAttributedString.Key: Any] = [
        .font: Font.bold.font(withSize: 11),
        .foregroundColor: UIColor.red,
        .paragraphStyle: NSParagraphStyle.default,
        .kern: 0.55
    ]

    let tabBarUnselectedItemTextAttributes: [NSAttributedString.Key: Any] = [
        .font: Font.bold.font(withSize: 11),
        .foregroundColor: UIColor.textSecondary,
        .paragraphStyle: NSParagraphStyle.default,
        .kern: 0.55
    ]

    // GRAY LIGHT 01

    let agentPrescribingInformationSectionLabelTextAttributes: [NSAttributedString.Key: Any] = [
        .font: Font.bold.font(withSize: 11),
        .foregroundColor: Color.textTertiary.value,
        .kern: 0.88
    ]

    // MARK: 12
    // MISC

    let informationLabelTextAttributesRed                    = Color.red65.attributes(font: .regular(12), style: .init(lineHeight: 16.0), kern: 0.4)
    let offlineModeSecondTextAttributes                      = Color.brand32.attributes(font: .regular(12), style: .init(lineHeight: 16.0, alignment: .center), kern: 0.4)
    let searchTagLabelTextAttributes                         = Color.gray15.attributes(font: .bold(12), style: .init(lineHeight: 16.0, alignment: .left), kern: 0.14)
    let informationLabelTextAttributes                       = Color.black11.attributes(font: .regular(12), style: .init(lineHeight: 16), kern: 0.4)

    lazy var galleryImageCopyrightTextAttributes: [NSAttributedString.Key: Any] = {
        [
            .font: Font.regular.font(withSize: 12.0),
            .foregroundColor: Color.gray25.value,
            .paragraphStyle: NSMutableParagraphStyle(lineHeight: 15)
        ]
    }()

    lazy var galleryImageCopyrightLinkTextAttributes: [NSAttributedString.Key: Any] = [
        .font: Font.regular.font(withSize: 12),
        .foregroundColor: Color.brand32.value,
        .paragraphStyle: NSMutableParagraphStyle(lineHeight: 15)
    ]

    lazy var searchMediaViewMoreTitleTextAttributes: [NSAttributedString.Key: Any] = {
        [
            .font: Font.bold.font(withSize: 12),
            .foregroundColor: tintColor,
            .paragraphStyle: searchResultMediaViewMoreTitleParagraphStyle,
            .kern: 0.6
        ]
    }()

    // GRAY DARK 01

    let dashboardSectionTitleTextAttributes = Color.grayDark01.attributes(font: .bold(12), style: .init(lineHeight: 16), kern: 0.6)

    // GRAY 55

    let agentPrescribingInformationSubtitleLabelTextAttributes = Color.gray55.attributes(font: .regular(12))
    let agentPatientPackageSubtitleLabelTextAttributes         = Color.textTertiary.attributes(font: .regular(12))

    // GRAY 40

    let searchMediaViewTypeTextAttributes = Color.textSecondary.attributes(font: .bold(12), kern: 0.88)

    var newsfeedPublishTextAttributes                = Color.textSecondary.attributes(font: .regular(12), style: .init(lineHeight: 16), kern: 0.4)
    let offlineModeFirstTextAttributes               = Color.textSecondary.attributes(font: .regular(12), style: .init(lineHeight: 16, alignment: .center))
    let userStageCellDescriptionTextAttributes       = Color.textSecondary.attributes(font: .regular(12), style: .init(lineHeight: 16))
    let dashboardClinicalToolsSubtitleTextAttributes = Color.textSecondary.attributes(font: .regular(12))
    let dashboardClinicalToolsCountTextAttributes = Color.textTertiary.attributes(font: .bold(12))

    // BLACK 11

    let userStageFooterTextAttributes = Color.textPrimary.attributes(font: .regular(12), style: .init(lineHeight: 18))

    // BRAND LIGHT 32
    let dashboardUserStageButtonTextAttributes = Color.textAccent.attributes(font: .black(12), style: .init(lineHeight: 16, linebreakMode: .byTruncatingTail), kern: 1.4)

    // MARK: 14
    // MISC

    let searchTextFieldTextAttributes            = Color.grayDark02.attributes(font: .regular(14))
    let searchTextFieldPlaceholderTextAttributes = Color.textSecondary.attributes(font: .regular(14))
    let showAllButtonTitleTextAttributes         = Color.greenDark01.attributes(font: .medium(14), underline: .single)
    lazy var welcomeViewSubtitleTextAttributes   = Color.textOnAccent.attributes(font: .bold(14), style: .init(lineHeight: 24, alignment: welcomeScreenParagraphAlignment), kern: 0.35)

    // WHITE

    let searchFiltersTagSelectedTextAttributes          = Color.white.attributes(font: .bold(14))
    let contentListMessageButtonTitleAttributes         = Color.white.attributes(font: .bold(14), style: .init(alignment: .center))

    // BLACK 11

    let drugListItemVendorTextAttributes              = Color.black11.attributes(font: .regular(14))
    let drugListItemATCTextAttributes                 = Color.black11.attributes(font: .regular(14))
    let loginSSOHintTextAttributes                    = Color.black11.attributes(font: .regular(14), style: .init(lineHeight: 24), kern: 0.25, baselineOffset: 24 - Int(Font.regular.font(withSize: 14).lineHeight))
    lazy var searchMediaViewTitleTextAttributes       = Color.black11.attributes(font: .regular(14), style: searchResultCollectionViewCellBodyParagraph)

    // GRAY 15

    let drugListItemApplicationFormsTextAttributes                 = Color.gray15.attributes(font: .regular(14))
    let agentPrescribingInformationSectionValueLabelTextAttributes = Color.textPrimary.attributes(font: .regular(14), kern: 0.25)

    lazy var searchResultTableViewCellNormalBodyAttributes = Color.gray15.attributes(font: .regular(14), style: searchResultTableViewCellBodyParagraph, kern: 0.25)
    lazy var searchResultTableViewCellBoldBodyAttributes   = Color.gray15.attributes(font: .bold(14), style: searchResultTableViewCellBodyParagraph, kern: 0.25)
    lazy var searchResultTableViewCellItalicBodyAttributes = Color.gray15.attributes(font: .italic(14), style: searchResultTableViewCellBodyParagraph, kern: 0.25)
    let searchNoResultsViewSubtitleTextAttributes          = Color.gray15.attributes(font: .regular(14), style: .init(lineHeight: 24, alignment: .center), kern: 0.25)

    // BRAND 32

    lazy var searchResultTableViewCellNormalSubtitleAttributes           = Color.brand32.attributes(font: .regular(14), style: searchResultTableViewCellBodyParagraph, kern: 0.1)
    lazy var phrasionarySearchResultSecondaryTargetNormalTitleAttributes = Color.brand32.attributes(font: .regular(14), style: phrasionarySearchResultSecondaryTargetButtonTitleParagraphStyle)
    let didYouMeanTitleBoldBrandColorAttributes                          = Color.brand32.attributes(font: .regular(14), style: .init(lineHeight: 14), kern: 0.4)
    let iAPBannerViewSubtitleTextAttributes                              = Color.brand32.attributes(font: .regular(14), style: .init(lineHeight: 22, alignment: .left), kern: 0.25, baselineOffset: 2)
    lazy var searchResultTableViewCellItalicSubtitleAttributes           = Color.brand32.attributes(font: .italic(14), style: searchResultTableViewCellBodyParagraph, kern: 0.1)
    lazy var phrasionarySearchResultSecondaryTargetItalicTitleAttributes = Color.brand32.attributes(font: .italic(14), style: phrasionarySearchResultSecondaryTargetButtonTitleParagraphStyle)
    let searchResultTableViewHeaderButtonTitleAttributes                 = Color.textAccent.attributes(font: .bold(14))
    let didYouMeanTitleBoldBrandColorkUnderlineAttributes                = Color.brand32.attributes(font: .bold(14), kern: 0.4, underline: .single)
    let signUpAlreadyRegisteredLabelTextAttributes                       = Color.textAccent.attributes(font: .bold(14), style: .init(lineHeight: 16, alignment: .center))
    let dashboardSectionHeaderButtonTitleAttributes                      = Color.textAccent.attributes(font: .bold(14), style: .init(lineHeight: 16))
    lazy var searchResultTableViewCellBoldSubtitleAttributes             = Color.brand32.attributes(font: .bold(14), style: searchResultTableViewCellBodyParagraph, kern: 0.1)
    lazy var phrasionarySearchResultSecondaryTargetBoldTitleAttributes   = Color.brand32.attributes(font: .bold(14), style: phrasionarySearchResultSecondaryTargetButtonTitleParagraphStyle)

    // GRAY DARK 01

    let iAPStoreViewInfoSubtitleTextAttributes         = Color.grayDark01.attributes(font: .regular(14), style: .init(lineHeight: 24, alignment: .left), kern: 0.25, baselineOffset: 2)
    let iAPStoreViewInfoSubtitleCenteredTextAttributes = Color.grayDark01.attributes(font: .regular(14), style: .init(lineHeight: 24, alignment: .center), kern: 0.25, baselineOffset: 2)
    let searchResultTableViewHeaderTitleAttributes     = Color.grayDark01.attributes(font: .bold(14), kern: 0.1)
    let iAPBannerViewTitleTextAttributes               = Color.grayDark01.attributes(font: .bold(14), style: .init(lineHeight: 22, alignment: .left), kern: 0.1, baselineOffset: 2)
    let iAPStoreViewInfoTitleTextAttributes            = Color.textPrimary.attributes(font: .bold(14), style: .init(lineHeight: 24, alignment: .left), kern: 0.1, baselineOffset: 2)
    let iAPStoreViewSubtitleTextAttributes             = Color.grayDark01.attributes(font: .bold(14), style: .init(lineHeight: 24, alignment: .center), kern: 0.1, baselineOffset: 4)
    let dashboardClinicalToolsTitleTextAttributes      = Color.textSecondary.attributes(font: .bold(14))
    let libraryViewTitleLabelTextAttributes            = Color.textSecondary.attributes(font: .bold(14))
    let searchFiltersTagNormalTextAttributes           = Color.grayDark01.attributes(font: .bold(14))

    // GRAY 45

    let settingsLibraryAndPharmaDeleteDisclaimerTextAttributes = Color.gray45.attributes(font: .regular(14))
    let extensionCellButtonTextAttributes                      = Color.textTertiary.attributes(font: .bold(14))

    // BLACK 11

    var newsfeedContentTextAttributes = Color.black11.attributes(font: .regular(14), style: .init(lineHeight: 24), kern: 0.25)

    // GRAY 40

    let drugListItemPricesAndPackageSizesTextAttributes = Color.textTertiary.attributes(font: .regular(14))
    let snippetEtymologyTextAttributes                  = Color.gray40.attributes(font: .italic(14), style: .init(lineHeight: 20), baselineOffset: 2)
    let snippetTargetButtonImageTint                    = Color.gray40.value
    let didYouMeanTitleItalicAttributes                 = Color.gray40.attributes(font: .italic(14), style: .init(lineHeight: 14), kern: 0.4)
    let clinicalReferenceItemTitleTextAttributes        = Color.gray40.attributes(font: .bold(14))
    let clinicalToolButtonTitleTextAttributes           = Color.gray40.attributes(font: .bold(14))
    let discoverAmbossSectionTitleTextAttributes        = Color.gray40.attributes(font: .bold(14), style: .init(lineHeight: 24))
    let contentListSearchFieldPlaceholderAttributes     = Color.gray40.attributes(font: .regular(14))
    let  contentListMessageSubtitleAttributes           = Color.gray40.attributes(font: .regular(14), style: .init(lineHeight: 20, alignment: .center))

    // GRAY 35

    let footerViewTextAttributes                       = Color.textSecondary.attributes(font: .regular(14), style: .init(lineHeight: 20))
    let agentPrescribingInformationLabelTextAttributes = Color.gray35.attributes(font: .bold(14))
    let agentPatientPackageLabelTextAttributes         = Color.gray35.attributes(font: .bold(14))

    // NIGHT BLACK DARK

    let headerTextAttributes             = Color.textTertiary.attributes(font: .bold(12))
    let signUpTitleLabelTextAttributes   = Color.nightBlackDark01.attributes(font: .bold(14), style: .init(lineHeight: 24), kern: 0.1)
    let userStageCellTitleTextAttributes = Color.nightBlackDark01.attributes(font: .bold(14), style: .init(lineHeight: 24))

    // MARK: 15
    // BLACK 11

    let settingsLibraryAndPharmaSubtitleTextAttributes = Color.black11.attributes(font: .regular(15))

    // MARK: 16
    // MISC

    let settingsDestructiveButtonTextAttributes = Color.red65.attributes(font: .bold(14))

    lazy var galleryImageDescriptionTextAttributes: [NSAttributedString.Key: Any] = [
        .font: Font.regular.font(withSize: 16),
        .foregroundColor: Color.gray25.value,
        .paragraphStyle: NSMutableParagraphStyle(lineHeight: 20),
        .kern: 0.5
    ]

    let miniMapChildTitleTextAttributes = Color.gray35.attributes(font: .regular(16), style: .init(lineHeight: 20))

    lazy var galleryImageTitleTextAttributes: [NSAttributedString.Key: Any] = {
        [
            .font: Font.bold.font(withSize: 16),
            .foregroundColor: textColor
        ]
    }()

    // NIGHT BLACK DARK

    let usagePurposeCellTitleTextAttributes = Color.nightBlackDark01.attributes(font: .regular(16))

    // GRAY 40
    let learningCardOptionsSwitchSubtitleAttributes = Color.textTertiary.attributes(font: .regular(16), style: .init(lineHeight: 24))

    // GRAY 15

    let searchSuggestionItemNormalTitleTextAttributes                   = Color.gray15.attributes(font: .regular(16))
    let searchSuggestionItemItalicTitleTextAttributes                   = Color.gray15.attributes(font: .italic(16))
    let searchHistoryTableViewCellTextAttributes                        = Color.textSecondary.attributes(font: .bold(16))
    let searchSuggestionItemBoldTitleTextAttributes                     = Color.gray15.attributes(font: .bold(16))
    lazy var searchResultTableViewCellNormalTitleNonClickableAttributes = Color.gray15.attributes(font: .bold(16), style: searchResultTableViewCellTitleParagraphStyle, kern: 0.25)
    let searchNoResultsViewTitleTextAttributes                          = Color.gray15.attributes(font: .bold(16), style: .init(lineHeight: 24, alignment: .center), kern: 0.1)

    // BRAND 32

    lazy var searchResultTableViewCellItalicTitleAttributes = Color.textAccent.attributes(font: .italic(16), style: searchResultTableViewCellTitleParagraphStyle)
    lazy var searchResultTableViewCellNormalTitleAttributes = Color.textAccent.attributes(font: .bold(16), style: searchResultTableViewCellTitleParagraphStyle, kern: 0.1)
    lazy var searchResultTableViewCellBoldTitleAttributes   = Color.textAccent.attributes(font: .bold(16), style: searchResultTableViewCellTitleParagraphStyle)

    // GRAY DARK 01

    lazy var dosagePopoverContentTextAttributes     = Color.grayDark01.attributes(font: .regular(16), style: leftAlignedLineHeight26, baselineOffset: 2)
    let snippetDescriptionTextAttributes            = Color.grayDark01.attributes(font: .regular(16), style: .init(lineHeight: 26), kern: 0, baselineOffset: 2)
    lazy var snippetTargetButtonTitleTextAttributes = Color.grayDark01.attributes(font: .regular(16), style: leftAlignedLineHeight24, baselineOffset: 2)
    lazy var dosageTargetButtonTitleTextAttributes  = Color.grayDark01.attributes(font: .regular(16), style: leftAlignedLineHeight24, baselineOffset: 2)
    let learningCardOptionsButtonTitleAttributes    = Color.grayDark01.attributes(font: .bold(16))
    let learningCardOptionsSwitchTitleAttributes    = Color.grayDark01.attributes(font: .bold(16))

    // WHITE

    let navigationBarTitleTextAttributes = Color.white.attributes(font: .bold(16))

    // BLACK 11

    let settingsLibraryAndPharmaNormalTextAttributes   = Color.black11.attributes(font: .regular(16))
    lazy var recentsListEmptyStateTextAttributes       = Color.textSecondary.attributes(font: .regular(16), style: .init(linebreakMode: .byWordWrapping, lineHeightMultiple: 1.25), baselineOffset: 2)
    let snippetSynonymTextAttributes                       = Color.black11.attributes(font: .italic(16), style: .init(lineHeight: 24), baselineOffset: 2)
    let textFieldTextAttributes                            = Color.black11.attributes(font: .bold(16))
    let miniMapParentTitleTextAttributes                   = Color.black11.attributes(font: .bold(16))
    let drugListItemTitleTextAttributes                    = Color.black11.attributes(font: .bold(16))
    let settingsLibraryAndPharmaTitleTextAttributes        = Color.textSecondary.attributes(font: .bold(16))
    let clinicalReferenceButtonTitleTextAttributes         = Color.black11.attributes(font: .bold(16))
    let learningCardOptionsSubheadingAttributes            = Color.textPrimary.attributes(font: .bold(16))
    lazy var newsfeedEntryTitleTextAttributes              = Color.black11.attributes(font: .bold(16), style: .init(lineHeight: 24), kern: 0.1)
    let drugListTitleTextAttributes                        = Color.black11.attributes(font: .bold(16), style: .init(lineHeight: 24, alignment: .center))
    lazy var snippetTitleTextAttributes                    = Color.black11.attributes(font: .bold(16), style: .init(linebreakMode: .byTruncatingTail), kern: 0.1, baselineOffset: 2)
    let popoverTitleTextAttributes                         = Color.textPrimary.attributes(font: .bold(16), style: .init(linebreakMode: .byTruncatingTail), kern: 0.1)
    let contentListMessageTitleAttributes                  = Color.black11.attributes(font: .bold(16), style: .init(lineHeight: 20, alignment: .center))

    // MARK: 17
    // MISC

    let libraryViewChildCountLabelTextAttributes = Color.textTertiary.attributes(font: .regular(12))
    let selectableCellDescriptionTextAttributes  = Color.brand32.attributes(font: .medium(17))

    // BLACK 11

    let selectableCellTitleTextAttributes               = Color.textPrimary.attributes(font: .medium(17))
    let emailTextViewBoldTextAttributes                 = Color.black11.attributes(font: .medium(17))
    let extensionCellTitleTextAttributes                = Color.textSecondary.attributes(font: .bold(17))

    // MARK: 18

    let iAPStoreViewTitleTextAttributes = Color.black11.attributes(font: .bold(18), style: .init(lineHeight: 22, alignment: .center))

    // MARK: 20

    let titleTextAttributes = Color.textPrimary.attributes(font: .black(20), style: .init(lineHeight: 20, alignment: .center))

    // MARK: 22
    // MISC

    lazy var welcomeViewTitleTextAttributes = Color.textOnAccent.attributes(font: .black(22), style: .init(lineHeight: 28, alignment: welcomeScreenParagraphAlignment), kern: 0.35)

    // MARK: 28
    // BLACK 11

    let activeIngredientTitleLabelTextAttributes = Color.textPrimary.attributes(font: .black(28))

    // MARK: 34

    let navigationBarLargeTitleTextAttributes = Color.white.attributes(font: .black(34), kern: 0.35)
}
