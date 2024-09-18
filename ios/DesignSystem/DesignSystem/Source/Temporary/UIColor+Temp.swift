//
//  UIColor+Temp.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 15.08.23.
//

import UIKit

// This is a temporary extension.
// There is currently no defenition for shadow color
// or elevation border color in the design system.
// This will be replaced by elevation tokens in the future
extension UIColor {
    public static var shadow: UIColor { UIColor.black.withAlphaComponent(0.07) }

    // Keeping elevationBorderColor = .clear in both light and dark modes for now,
    // The dark mode elevation border should be changed to UIColor(0x40454f66)
    // once our the elvation structure is finalized.
    public static var elevationBorder: UIColor { .init(light: .clear, dark: .borderSecondary) }
}
