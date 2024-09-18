//
//  UIButton+Convenience.swift
//  AmbossDesignSystem
//
//  Created by Roberto Seidenberg on 17.05.23.
//

import UIKit

extension UIControl {

    static func alphaValue(for state: UIControl.State) -> CGFloat {
        switch state {
        case .disabled: return 0.3
        default: return 1.0
        }
    }
}
