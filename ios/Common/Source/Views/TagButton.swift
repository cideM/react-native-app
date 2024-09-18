//
//  TagButton.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 22.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

public final class TagButton: UIButton {

    private var borderColor: [UIControl.State.RawValue: UIColor] = [:] {
        didSet {
            updateBorderColor()
        }
    }

    public func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let image = UIImage.from(color)
        setBackgroundImage(image, for: state)
    }

    public func setBorderColor(_ color: UIColor, for state: UIControl.State) {
        borderColor[state.rawValue] = color
    }

    override public var isHighlighted: Bool {
        didSet {
            updateBorderColor()
        }
    }

    override public var isSelected: Bool {
        didSet {
            updateBorderColor()
        }
    }

    override public var contentEdgeInsets: UIEdgeInsets {
        get {
            UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        }
        set {
            super.contentEdgeInsets = newValue
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2.0
    }

    private func updateBorderColor() {
        let borderColor = self.borderColor[state.rawValue] ?? self.borderColor[UIControl.State.normal.rawValue] ?? .clear
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = 2
        layer.masksToBounds = true
    }
}

public extension TagButton {
    struct Style {
        let backgroundColor: (normal: UIColor, highlighted: UIColor)
        let borderColor: (normal: UIColor, highlighted: UIColor)?

        public init(backgroundColor: (normal: UIColor, highlighted: UIColor), borderColor: (normal: UIColor, highlighted: UIColor)?) {
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
        }
    }
}
