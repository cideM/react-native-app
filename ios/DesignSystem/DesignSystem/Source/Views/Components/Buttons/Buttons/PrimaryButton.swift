//
//  PrimaryButton.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 13.12.23.
//

import UIKit

public class PrimaryButton: BaseButton {

    override internal func applyBackgroundColorForStates() {
        setBackgroundColor(.backgroundAccent, for: .normal)
        setBackgroundColor(.backgroundAccent, for: .highlighted, addHighlightOverlay: true)
        setBackgroundColor(.backgroundAccent.withAlphaComponent(0.5), for: .disabled)
    }

    override internal func normalTextColor() -> UIColor {
        .textOnAccent
    }

    override internal func highlightedTextColor() -> UIColor {
        .textOnAccentSubtle.withAlphaComponent(0.6)
    }

    override internal func disabledTextColor() -> UIColor {
        .textOnAccentSubtle.withAlphaComponent(0.5)
    }
}
