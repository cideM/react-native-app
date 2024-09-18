//
//  DestructiveButton.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 13.12.23.
//

import UIKit

public class DestructiveButton: BaseButton {

    override internal func applyBackgroundColorForStates() {
        setBackgroundColor(.backgroundError, borderColor: .textError, for: .normal)
        setBackgroundColor(.backgroundError, borderColor: .textError, for: .highlighted, addHighlightOverlay: true)
        setBackgroundColor(.backgroundError.withAlphaComponent(0.5), for: .disabled)
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
