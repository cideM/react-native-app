//
//  UIColor+Token.swift
//  AmbossDesignSystem
//
//  Created by Roberto Seidenberg on 04.04.23.
//

import UIKit

extension UIColor {

    fileprivate typealias C = DesignSystemColorTokens

    // MARK: - Background Colors
    public static var backgroundAccent: UIColor { .init( C.lightColorBackgroundAccent, C.darkColorBackgroundAccent) }
    public static var backgroundAccentSubtle: UIColor { .init( C.lightColorBackgroundAccentSubtle, C.darkColorBackgroundAccentSubtle) }
    public static var backgroundBackdrop: UIColor { .init( C.lightColorBackgroundBackdrop, C.darkColorBackgroundBackdrop) }
    public static var backgroundContrast: UIColor { .init( C.lightColorBackgroundContrast, C.darkColorBackgroundContrast) }
    public static var backgroundElevated: UIColor { .init( C.lightColorBackgroundElevated, C.darkColorBackgroundElevated) }
    public static var backgroundError: UIColor { .init( C.lightColorBackgroundError, C.darkColorBackgroundError) }
    public static var backgroundErrorSubtle: UIColor { .init( C.lightColorBackgroundErrorSubtle, C.darkColorBackgroundErrorSubtle) }
    public static var backgroundInfo: UIColor { .init( C.lightColorBackgroundInfo, C.darkColorBackgroundInfo) }
    public static var backgroundInfoSubtle: UIColor { .init( C.lightColorBackgroundInfoSubtle, C.darkColorBackgroundInfoSubtle) }
    public static var backgroundOnAccent: UIColor { .init( C.lightColorBackgroundOnAccent, C.darkColorBackgroundOnAccent) }
    public static var backgroundPrimary: UIColor { .init( C.lightColorBackgroundPrimary, C.darkColorBackgroundPrimary) }
    public static var backgroundSecondary: UIColor { .init( C.lightColorBackgroundSecondary, C.darkColorBackgroundSecondary) }
    public static var backgroundSuccess: UIColor { .init( C.lightColorBackgroundSuccess, C.darkColorBackgroundSuccess) }
    public static var backgroundSuccessSubtle: UIColor { .init( C.lightColorBackgroundSuccessSubtle, C.darkColorBackgroundSuccessSubtle) }
    public static var backgroundTransparent: UIColor { .init( C.lightColorBackgroundTransparent, C.darkColorBackgroundTransparent) }
    public static var backgroundWarning: UIColor { .init( C.lightColorBackgroundWarning, C.darkColorBackgroundWarning) }
    public static var backgroundWarningSubtle: UIColor { .init( C.lightColorBackgroundWarningSubtle, C.darkColorBackgroundWarningSubtle) }
    public static var backgroundTextHighlightFind: UIColor { .init( C.lightColorBackgroundTextHighlightFind, C.darkColorBackgroundTextHighlightFind) }
    public static var backgroundTextHighlightPrimary: UIColor { .init( C.lightColorBackgroundTextHighlightPrimary, C.darkColorBackgroundTextHighlightPrimary) }
    public static var backgroundTextHighlightSecondary: UIColor { .init( C.lightColorBackgroundTextHighlightSecondary, C.darkColorBackgroundTextHighlightSecondary) }
    public static var backgroundTextHighlightRelevancePrimary: UIColor { .init(C.lightColorBackgroundTextHighlightRelevancePrimary, C.darkColorBackgroundTextHighlightRelevancePrimary) }
    public static var backgroundTextHighlightRelevanceSecondary: UIColor { .init(C.lightColorBackgroundTextHighlightRelevanceSecondary, C.darkColorBackgroundTextHighlightRelevanceSecondary) }
    public static var backgroundTransparentSelected: UIColor { .init( C.lightColorBackgroundTransparentSelected, C.darkColorBackgroundTransparentSelected) }

    // MARK: - Border Colors
    public static var borderAccent: UIColor { .init( C.lightColorBorderAccent, C.darkColorBorderAccent) }
    public static var borderAccentSubtle: UIColor { .init( C.lightColorBorderAccentSubtle, C.darkColorBorderAccentSubtle) }
    public static var borderError: UIColor { .init( C.lightColorBorderError, C.darkColorBorderError) }
    public static var borderOnAccent: UIColor { .init( C.lightColorBorderOnAccent, C.darkColorBorderOnAccent) }
    public static var borderPrimary: UIColor { .init( C.lightColorBorderPrimary, C.darkColorBorderPrimary) }
    public static var borderSecondary: UIColor { .init( C.lightColorBorderSecondary, C.darkColorBorderSecondary) }

    // MARK: - Canvas Colors
    public static var canvas: UIColor { .init( C.lightColorCanvas, C.darkColorCanvas) }

    // MARK: - Divider Colors
    public static var dividerPrimary: UIColor { .init( C.lightColorDividerPrimary, C.darkColorDividerPrimary) }
    public static var dividerSecondary: UIColor { .init( C.lightColorDividerSecondary, C.darkColorDividerSecondary) }

    // MARK: - Icon Colors
    public static var iconAccent: UIColor { .init( C.lightColorIconAccent, C.darkColorIconAccent) }
    public static var iconBrand: UIColor { .init( C.lightColorIconBrand, C.darkColorIconBrand) }
    public static var iconError: UIColor { .init( C.lightColorIconError, C.darkColorIconError) }
    public static var iconInfo: UIColor { .init( C.lightColorIconInfo, C.darkColorIconInfo) }
    public static var iconOnAccent: UIColor { .init( C.lightColorIconOnAccent, C.darkColorIconOnAccent) }
    public static var iconOnAccentSubtle: UIColor { .init( C.lightColorIconOnAccentSubtle, C.darkColorIconOnAccentSubtle) }
    public static var iconPrimary: UIColor { .init( C.lightColorIconPrimary, C.darkColorIconPrimary) }
    public static var iconQuaternary: UIColor { .init( C.lightColorIconQuaternary, C.darkColorIconQuaternary) }
    public static var iconSecondary: UIColor { .init( C.lightColorIconSecondary, C.darkColorIconSecondary) }
    public static var iconSuccess: UIColor { .init( C.lightColorIconSuccess, C.darkColorIconSuccess) }
    public static var iconTertiary: UIColor { .init( C.lightColorIconTertiary, C.darkColorIconTertiary) }
    public static var iconWarning: UIColor { .init( C.lightColorIconWarning, C.darkColorIconWarning) }
    public static var icconOnAccentSubtle: UIColor { .init(C.lightColorIconOnAccentSubtle, C.darkColorIconOnAccentSubtle) }

    // MARK: - Text Colors
    public static var textAccent: UIColor { .init( C.lightColorTextAccent, C.darkColorTextAccent) }
    public static var textDottedUnderline: UIColor { .init( C.lightColorTextDottedUnderline, C.darkColorTextDottedUnderline) }
    public static var textError: UIColor { .init( C.lightColorTextError, C.darkColorTextError) }
    public static var textInfo: UIColor { .init( C.lightColorTextInfo, C.darkColorTextInfo) }
    public static var textOnAccent: UIColor { .init( C.lightColorTextOnAccent, C.darkColorTextOnAccent) }
    public static var textPrimary: UIColor { .init( C.lightColorTextPrimary, C.darkColorTextPrimary) }
    public static var textQuaternary: UIColor { .init( C.lightColorTextQuaternary, C.darkColorTextQuaternary) }
    public static var textSecondary: UIColor { .init( C.lightColorTextSecondary, C.darkColorTextSecondary) }
    public static var textSuccess: UIColor { .init( C.lightColorTextSuccess, C.darkColorTextSuccess) }
    public static var textTertiary: UIColor { .init( C.lightColorTextTertiary, C.darkColorTextTertiary) }
    public static var textUnderline: UIColor { .init( C.lightColorTextUnderline, C.darkColorTextUnderline) }
    public static var textWarning: UIColor { .init( C.lightColorTextWarning, C.darkColorTextWarning) }
    public static var textOnAccentSubtle: UIColor { .init( C.lightColorTextOnAccentSubtle, C.darkColorTextOnAccentSubtle) }
}
