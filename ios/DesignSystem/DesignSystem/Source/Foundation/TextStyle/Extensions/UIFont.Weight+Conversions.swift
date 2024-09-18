//
//  UIFont.Weight+Conversions.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.08.23.
//

import UIKit

extension UIFont.Weight {
    /// Available CSS font weight values are: 100, 200, 300, 400,..., 900
    /// with 400 being the .regular font weight and 900 being .black
    /// But the available iOS font values are the decimal numbers between -1 and 1
    /// with -1 being the .ultraLight font weight,
    /// 0 being the regular, and 1 being the .black
    static func fromCSSValue(_ value: CGFloat) -> UIFont.Weight {

        switch value {
        case 100: return .ultraLight
        case 200: return .thin
        case 300: return .light
        case 400: return .regular
        case 500: return .medium
        case 600: return .semibold
        case 700: return .bold
        case 800: return .heavy
        case 900: return .black
        default: return convertedFromCSSValue(value)
        }
    }

    private static func convertedFromCSSValue(_ value: CGFloat) -> UIFont.Weight {
        // This function approximates a conversion from the CSS statndard scale to the UIFont.Weight scale
        let discreetValue = value / 100
        if Int(discreetValue) < 4 {
            return UIFont.Weight(rawValue: (discreetValue - 4) * (1.0 / 3.0))
        } else {
            let weight = (discreetValue - 4) * (1.0 / 5.0)
            return UIFont.Weight(rawValue: weight)
        }
    }
}
