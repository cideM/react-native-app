//
//  UIColor+Init.swift
//  AmbossDesignSystem
//
//  Created by Roberto Seidenberg on 04.04.23.
//

import ObjectiveC
import UIKit

public extension UIColor {

    // This initialiser accepts a 32 bit hex fragment of format:
    // The alpha digit is optional
    // If alpha is omitted, the value will be considered opaque
    // 0xFF______ = alpha
    // 0x__FF____ = red
    // 0x____FF__ = green
    // 0x______FF = blue
    convenience init(_ hex: UInt64) {
        var r, g, b, a: CGFloat
        if hex <= 0xFFFFFF {
            // Hex without alpha (6 hex digits)
            a = 1.0
            r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
            g = CGFloat((hex & 0x00FF00) >> 8) / 255.0
            b = CGFloat(hex & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        } else {
            // Hex including alpha (8 hex digits)
            a = CGFloat((hex & 0xFF000000) >> 24) / 255.0
            r = CGFloat((hex & 0x00FF0000) >> 16) / 255.0
            g = CGFloat((hex & 0x0000FF00) >> 8) / 255.0
            b = CGFloat(hex & 0x000000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: a)
        }
    }

    convenience init(_ light: UInt64, _ dark: UInt64? = nil) {
        self.init { traitCollection in
            let isDark = traitCollection.userInterfaceStyle == .dark
            let hex = (isDark ? dark : light) ?? light
            return .init(hex)
        }
    }

    convenience init (_ light: UIColor, _ dark: UIColor) {
        self.init { traitCollection in
            let isDark = traitCollection.userInterfaceStyle == .dark
            return isDark ? dark : light
        }
    }

    @available(*, deprecated, message: "Remove when UIColor+Temp is deleted")
    convenience init (light: UIColor, dark: UIColor) {
        self.init(light, dark)
    }
}

public extension UIColor {

    static func alphaValue(for state: UIControl.State) -> CGFloat {
        switch state {
        case .highlighted: return 0.12
        default: return 1.0
        }
    }

    func adapted(for state: UIControl.State) -> UIColor {
        withAlphaComponent(UIColor.alphaValue(for: state))
    }
}
