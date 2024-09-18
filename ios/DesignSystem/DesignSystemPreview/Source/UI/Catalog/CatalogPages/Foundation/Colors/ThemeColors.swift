//
//  DynamicThemeColors.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 05.09.23.
//

import UIKit
import DesignSystem

public enum ThemeColors: String, CaseIterable {

    case backgroundAccent
    case backgroundAccentSubtle
    case backgroundBackdrop
    case backgroundContrast
    case backgroundElevated
    case backgroundError
    case backgroundErrorSubtle
    case backgroundInfo
    case backgroundInfoSubtle
    case backgroundOnAccent
    case backgroundPrimary
    case backgroundSecondary
    case backgroundSuccess
    case backgroundSuccessSubtle
    case backgroundTextHighlightFind
    case backgroundTextHighlightPrimary
    case backgroundTextHighlightRelevancePrimary
    case backgroundTextHighlightRelevanceSecondary
    case backgroundTextHighlightSecondary
    case backgroundTransparent
    case backgroundTransparentSelected
    case backgroundWarning
    case backgroundWarningSubtle
    case borderAccent
    case borderAccentSubtle
    case borderError
    case borderOnAccent
    case borderPrimary
    case borderSecondary
    case canvas
    case dividerPrimary
    case dividerSecondary
    case iconAccent
    case iconBrand
    case iconError
    case iconInfo
    case iconOnAccent
    case iconOnAccentSubtle
    case iconPrimary
    case iconQuaternary
    case iconSecondary
    case iconSuccess
    case iconTertiary
    case iconWarning
    case textAccent
    case textDottedUnderline
    case textError
    case textInfo
    case textOnAccent
    case textOnAccentSubtle
    case textPrimary
    case textQuaternary
    case textSecondary
    case textSuccess
    case textTertiary
    case textUnderline
    case textWarning

    public func value() -> UIColor {

        switch self {
        case .backgroundAccent: return UIColor.backgroundAccent
        case .backgroundAccentSubtle: return UIColor.backgroundAccentSubtle
        case .backgroundBackdrop: return UIColor.backgroundBackdrop
        case .backgroundContrast: return UIColor.backgroundContrast
        case .backgroundElevated: return UIColor.backgroundElevated
        case .backgroundError: return UIColor.backgroundError
        case .backgroundErrorSubtle: return UIColor.backgroundErrorSubtle
        case .backgroundInfo: return UIColor.backgroundInfo
        case .backgroundInfoSubtle: return UIColor.backgroundInfoSubtle
        case .backgroundOnAccent: return UIColor.backgroundOnAccent
        case .backgroundPrimary: return UIColor.backgroundPrimary
        case .backgroundSecondary: return UIColor.backgroundSecondary
        case .backgroundSuccess: return UIColor.backgroundSuccess
        case .backgroundSuccessSubtle: return UIColor.backgroundSuccessSubtle
        case .backgroundTextHighlightFind: return UIColor.backgroundTextHighlightFind
        case .backgroundTextHighlightPrimary: return UIColor.backgroundTextHighlightPrimary
        case .backgroundTextHighlightRelevancePrimary: return UIColor.backgroundTextHighlightRelevancePrimary
        case .backgroundTextHighlightRelevanceSecondary: return UIColor.backgroundTextHighlightRelevanceSecondary
        case .backgroundTextHighlightSecondary: return UIColor.backgroundTextHighlightSecondary
        case .backgroundTransparent: return UIColor.backgroundTransparent
        case .backgroundTransparentSelected: return UIColor.backgroundTransparentSelected
        case .backgroundWarning: return UIColor.backgroundWarning
        case .backgroundWarningSubtle: return UIColor.backgroundWarningSubtle
        case .borderAccent: return UIColor.borderAccent
        case .borderAccentSubtle: return UIColor.borderAccentSubtle
        case .borderError: return UIColor.borderError
        case .borderOnAccent: return UIColor.borderOnAccent
        case .borderPrimary: return UIColor.borderPrimary
        case .borderSecondary: return UIColor.borderSecondary
        case .canvas: return UIColor.canvas
        case .dividerPrimary: return UIColor.dividerPrimary
        case .dividerSecondary: return UIColor.dividerSecondary
        case .iconAccent: return UIColor.iconAccent
        case .iconBrand: return UIColor.iconBrand
        case .iconError: return UIColor.iconError
        case .iconInfo: return UIColor.iconInfo
        case .iconOnAccent: return UIColor.iconOnAccent
        case .iconOnAccentSubtle: return UIColor.iconOnAccentSubtle
        case .iconPrimary: return UIColor.iconPrimary
        case .iconQuaternary: return UIColor.iconQuaternary
        case .iconSecondary: return UIColor.iconSecondary
        case .iconSuccess: return UIColor.iconSuccess
        case .iconTertiary: return UIColor.iconTertiary
        case .iconWarning: return UIColor.iconWarning
        case .textAccent: return UIColor.textAccent
        case .textDottedUnderline: return UIColor.textDottedUnderline
        case .textError: return UIColor.textError
        case .textInfo: return UIColor.textInfo
        case .textOnAccent: return UIColor.textOnAccent
        case .textOnAccentSubtle: return UIColor.textOnAccentSubtle
        case .textPrimary: return UIColor.textPrimary
        case .textQuaternary: return UIColor.textQuaternary
        case .textSecondary: return UIColor.textSecondary
        case .textSuccess: return UIColor.textSuccess
        case .textTertiary: return UIColor.textTertiary
        case .textUnderline: return UIColor.textUnderline
        case .textWarning: return UIColor.textWarning
        }
    }
}
