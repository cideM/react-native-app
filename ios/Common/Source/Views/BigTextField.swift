//
//  BigTextField.swift
//  Common
//
//  Created by CSH on 06.02.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit
import DesignSystem

@IBDesignable
public class BigTextField: UITextField {

    @IBInspectable
    public var isPasswordEntry: Bool = false {
        didSet {
            updateRightView()
        }
    }

    public private(set) lazy var rightButtonView: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        button.tintColor = ThemeManager.currentTheme.textFieldSubviewColor
        button.isHidden = true
        return button
    }()

    public var rightButtonTappedClosure: () -> Void = { }
    public var padding = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 54)

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    @discardableResult
    override public func becomeFirstResponder() -> Bool {
        guard super.becomeFirstResponder() else {
            return false
        }
        rightButtonView.isHidden = false
        self.layer.borderColor = UIColor.borderAccent.cgColor
        return true
    }

    override public func resignFirstResponder() -> Bool {
        guard super.resignFirstResponder() else {
            return false
        }
        rightButtonView.isHidden = true
        self.layer.borderColor = UIColor.backgroundAccentSubtle.cgColor
        return true
    }

    private func commonInit() {
        rightView = rightButtonView
        rightViewMode = .always
        backgroundColor = .backgroundSecondary
        layer.cornerRadius = 5.0
        layer.borderColor = UIColor.backgroundAccentSubtle.cgColor
        layer.borderWidth = 1.0
        font = Font.medium.font(withSize: 17)
        textColor = .textOnAccent
        updateRightView()
    }

    private func updateRightView() {
        if isPasswordEntry {
            let asset: ImageAsset = isSecureTextEntry ? Asset.eyeOff : Asset.eye
            rightButtonView.setImage(asset.image, for: .normal)
        } else {
            rightButtonView.setImage(Common.Asset.xCircle.image, for: .normal)
        }
        rightButtonView.frame.size = rightButtonView.imageView?.image?.size ?? .zero
    }

    @objc func rightButtonTapped() {
        if isPasswordEntry {
            rightButtonTappedClosure()
            isSecureTextEntry.toggle()
            updateRightView()
        } else {
            text = ""
            rightButtonTappedClosure()
            sendActions(for: .editingChanged)
        }
    }

    override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 10
        return rect
    }

    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}
