//
//  UITraitCollection+Convenience.swift
//  AmbossDesignSystem
//
//  Created by Roberto Seidenberg on 04.04.23.
//

import UIKit

extension UITraitCollection {

    var isLight: Bool {
        switch self.userInterfaceStyle {
        case .dark: return false
        default: return true
        }
    }
}
