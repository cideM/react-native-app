//
//  PrimaryButton_Experimental.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 18.12.23.
//

import UIKit

public class PrimaryButton_Experimental: BaseButton {

    override internal func applyBackgroundColorForStates() {
        setBackgroundColor(.backgroundAccent, borderColor: .borderAccentSubtle, for: .normal)
        setBackgroundColor(.backgroundAccent, borderColor: .borderAccentSubtle, for: .highlighted, addHighlightOverlay: true)
        setBackgroundColor(.backgroundAccent.withAlphaComponent(0.5), borderColor: .borderAccentSubtle, for: .disabled)
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
