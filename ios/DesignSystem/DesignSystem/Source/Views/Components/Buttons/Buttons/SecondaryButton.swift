//
//  SecondaryButton.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 13.12.23.
//

import UIKit

public class SecondaryButton: BaseButton {

    public enum Mode {
        case onAccentBackgroundColor
        case onPrimaryBackgroundColor
    }

    private let mode: Mode

    // MARK: - Initialization

    public required init(mode: Mode) {
        self.mode = mode
        super.init(frame: .zero)
    }

    // Used by WelcomeViewController.xib
    required init?(coder: NSCoder) {
        mode = .onAccentBackgroundColor
        super.init(coder: coder)
    }

    override internal func applyBackgroundColorForStates() {
        switch mode {
        case .onAccentBackgroundColor:
            setBackgroundColor(.clear, borderColor: .borderOnAccent, for: .normal)
            setBackgroundColor(.backgroundPrimary, borderColor: .borderOnAccent, for: .highlighted)
            setBackgroundColor(.clear, borderColor: .borderOnAccent.withAlphaComponent(0.5), for: .disabled)
        case .onPrimaryBackgroundColor:
            setBackgroundColor(.clear, borderColor: .borderPrimary, for: .normal)
            setBackgroundColor(.backgroundPrimary, borderColor: .borderSecondary, for: .highlighted)
            setBackgroundColor(.clear, borderColor: .borderSecondary.withAlphaComponent(0.5), for: .disabled)
        }
    }

    override internal func normalTextColor() -> UIColor {
        switch mode {
        case .onAccentBackgroundColor: .textOnAccent
        case .onPrimaryBackgroundColor: .textSecondary
        }
    }

    override internal func highlightedTextColor() -> UIColor {
        switch mode {
        case .onAccentBackgroundColor: .textOnAccentSubtle
        case .onPrimaryBackgroundColor: .textSecondary
        }

    }

    override internal func disabledTextColor() -> UIColor {
        switch mode {
        case .onAccentBackgroundColor: .textOnAccent.withAlphaComponent(0.5)
        case .onPrimaryBackgroundColor: .textPrimary.withAlphaComponent(0.5)
        }
    }

    override internal func textStyle() -> TextStyle {
        switch mode {
        case .onAccentBackgroundColor: .paragraphBold
        case .onPrimaryBackgroundColor: .paragraphSmallBold
        }
    }
}
