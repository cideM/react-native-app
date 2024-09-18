//
//  TextFieldLayer.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 22.11.23.
//

import UIKit

internal class TextFieldLayer: CALayer {

    // MARK: - Private
    private var _traitCollection: UITraitCollection?
    private var traitCollection: UITraitCollection {
        _traitCollection ?? .current
    }

    // MARK: - Internal
    internal var componentState: UIControl.State = .normal {
        didSet {
            applyStyle()
        }
    }

    internal var isValidInput = true {
        didSet {
            applyValidatorStateStyle()
        }
    }

    // MARK: - Initialization
    override internal init() {
        super.init()
        commonInit()
    }

    override internal init(layer: Any) {
        super.init(layer: layer)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        borderWidth = 1
        borderColor = UIColor.clear.cgColor
        backgroundColor = UIColor.clear.cgColor
        apply(cornerRadius: .radius.s)
    }

    // MARK: - Styling
    private func applyStyle() {
        if isValidInput == false { return }
        self.traitCollection.performAsCurrent {
            switch componentState {
            case .normal:
                self.borderColor = UIColor.borderPrimary.cgColor
                self.backgroundColor = UIColor.backgroundPrimary.cgColor
            case .disabled:
                self.borderColor = UIColor.borderSecondary.cgColor
                self.backgroundColor = UIColor.backgroundSecondary.cgColor
            case .focused:
                self.borderColor = UIColor.borderAccent.cgColor
                self.backgroundColor = UIColor.backgroundPrimary.cgColor
            default:
                break
            }
        }
    }

    private func applyValidatorStateStyle() {
        if isValidInput {
            applyStyle()
        } else {
            self.traitCollection.performAsCurrent {
                self.borderColor = UIColor.borderError.cgColor
                self.backgroundColor = UIColor.backgroundPrimary.cgColor
            }
        }
    }

    // CALayer does not conform to UITraitEnvironment
    // which means: it does not react to any UITraitCollection changes
    // which means: it does not react by itself to light/dark mode changes
    // which means: we need to do this manually via _traitCollection
    internal func userTraitDidChange(traitCollection: UITraitCollection) {
        _traitCollection = traitCollection
        applyStyle()
        applyValidatorStateStyle()
    }
}
