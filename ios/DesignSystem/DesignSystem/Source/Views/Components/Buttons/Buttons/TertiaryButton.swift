//
//  TertiaryButton.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 13.12.23.
//

import UIKit

public class TertiaryButton: BaseButton {

    override internal func applyBackgroundColorForStates() {
        setBackgroundColor(.clear, for: .normal)
        setBackgroundColor(.clear, for: .highlighted)
        setBackgroundColor(.clear, for: .disabled)
    }

    override internal func normalTextColor() -> UIColor {
        .textSecondary
    }

    override internal func textStyle() -> TextStyle {
        .h6
    }

    override internal func highlightedTextColor() -> UIColor {
        .textPrimary
    }

    override internal func disabledTextColor() -> UIColor {
        .textPrimary.withAlphaComponent(0.5)
    }
}
