//
//  BigButton.swift
//  Common
//
//  Created by CSH on 30.01.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit
import DesignSystem

open class BigButton: UIButton {

    public var imageScaleMode: ImageScaling = .matchTitleTextHeight {
        didSet {
            switch imageScaleMode {
            case .none:
                imageView?.contentMode = .center
                imageView?.clipsToBounds = false
            case .matchTitleTextHeight:
                imageView?.contentMode = .scaleAspectFit
                imageView?.clipsToBounds = true
            }
        }
    }

    private var normalBackgroundColor: UIColor = ThemeManager.currentTheme.bigButtonNormalBackgroundColor
    private var normalBorderColor: UIColor = ThemeManager.currentTheme.bigButtonNormalBorderColor
    private var normalFontColor: UIColor = ThemeManager.currentTheme.bigButtonNormalFontColor

    private var disabledBackgroundColor: UIColor = ThemeManager.currentTheme.bigButtonDisabledBackgroundColor
    private var disabledBorderColor: UIColor = ThemeManager.currentTheme.bigButtonDisabledBorderColor
    private var disabledFontColor: UIColor = ThemeManager.currentTheme.bigButtonDisabledFontColor

    private var cornerRadius: CGFloat = 4.0
    private var borderWidth: CGFloat = 1.0

    private var normalFont = Font.black.font(withSize: 14)

    private var imageAlignment: Alignment = .regular

    public var style: Style = .normal {
        didSet {
            switch style {
            case .primary: setPrimaryStyleDefaults()
            case .normal: setSecondaryStyleDefaults()
            case .link: setLinkStyleDefaults()
            case .linkWithBorders: setlinkWithBordersStyleDefaults()
            case .linkExternal: setLinkExternalStyleDefaults()
            case .welcome: setWelcomeStyleDefaults()
            case .welcomeInverted: setWelcomeInvertedStyleDefaults()
            }
            updateStyle()
        }
    }

    override open var intrinsicContentSize: CGSize {
        // WORKAROUND:
        // "titleLabel" may return an erroneous "intrinsicContentSize"
        // Which leads to insufficient border spacing around the title
        // Calculating the intrinsic height here manually
        // in a hacky way via bounds fixes this ...
        var size = super.intrinsicContentSize
        let titleHeight = titleLabel?.bounds.height ?? 0
        let imageHeight = imageView?.bounds.height ?? 0
        let maxImageOrLabel = max(titleHeight, imageHeight)
        let maxHeight = max(size.height, maxImageOrLabel + contentEdgeInsets.top + contentEdgeInsets.bottom)

        size.height = maxHeight
        return size
    }

    /// Sets the default colors for a primary button.
    private func setPrimaryStyleDefaults() {
        normalBackgroundColor = .backgroundAccent
        normalBorderColor = .clear
        normalFontColor = .textOnAccent
        disabledBackgroundColor = .backgroundAccent.withAlphaComponent(0.38)
        disabledBorderColor = .clear
        disabledFontColor = .textOnAccent.withAlphaComponent(0.38)
    }

    /// Sets the default colors for a secondary button.
    private func setSecondaryStyleDefaults() {
        normalBackgroundColor = .backgroundPrimary
        normalBorderColor = .borderSecondary
        normalFontColor = .textSecondary
        disabledBackgroundColor = .backgroundPrimary
        disabledBorderColor = .borderSecondary
        disabledFontColor = .textTertiary
    }

    /// Sets the default colors for a link button.
    private func setLinkStyleDefaults() {
        normalBackgroundColor = ThemeManager.currentTheme.linkButtonBackgroundColor
        normalBorderColor = ThemeManager.currentTheme.linkButtonBorderColor
        normalFontColor = ThemeManager.currentTheme.linkButtonTextColor
        disabledBackgroundColor = ThemeManager.currentTheme.disabledLinkButtonBackgroundColor
        disabledBorderColor = ThemeManager.currentTheme.disabledLinkButtonBorderColor
        disabledFontColor = ThemeManager.currentTheme.disabledLinkButtonTextColor
    }

    private func setlinkWithBordersStyleDefaults() {
        normalBackgroundColor = ThemeManager.currentTheme.linkButtonBackgroundColor
        normalBorderColor = ThemeManager.currentTheme.linkWithBordersButtonBorderColor
        normalFontColor = ThemeManager.currentTheme.linkButtonTextColor
        disabledBackgroundColor = ThemeManager.currentTheme.disabledLinkButtonBackgroundColor
        disabledBorderColor = ThemeManager.currentTheme.disabledLinkButtonBorderColor
        disabledFontColor = ThemeManager.currentTheme.disabledLinkButtonTextColor
        imageAlignment = .left
    }

    private func setWelcomeStyleDefaults() {
        normalBackgroundColor = .backgroundPrimary
        normalBorderColor = .clear
        normalFontColor = .textAccent
        normalFont = Font.bold.font(withSize: 16)
        cornerRadius = 4.0
    }

    private func setWelcomeInvertedStyleDefaults() {
        normalBackgroundColor = .clear
        normalBorderColor = .borderAccent
        normalFontColor = .textOnAccent
        cornerRadius = 8.0
    }

    /// Sets the default colors for a external link button.
    private func setLinkExternalStyleDefaults() {
        normalBackgroundColor = ThemeManager.currentTheme.linkButtonBackgroundColor
        normalBorderColor = ThemeManager.currentTheme.linkButtonBorderColor
        normalFontColor = ThemeManager.currentTheme.linkExternalButtonTextColor
        disabledBackgroundColor = ThemeManager.currentTheme.disabledLinkButtonBackgroundColor
        disabledBorderColor = ThemeManager.currentTheme.disabledLinkButtonBorderColor
        disabledFontColor = ThemeManager.currentTheme.disabledLinkButtonTextColor
        imageAlignment = .left
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defer {
            // defering, so the didSet will be called
            style = .normal
        }
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        defer {
            // defering, so the didSet will be called
            style = .normal
        }
        commonInit()
    }

    private func commonInit() {
        titleLabel?.lineBreakMode = .byWordWrapping
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 11, bottom: 11, right: 11)
        imageView?.contentMode = .scaleAspectFit
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }

    override open var isEnabled: Bool {
        didSet {
            if isEnabled != oldValue {
                updateStyle()
            }
        }
    }

    private func updateStyle() {
        titleLabel?.font = normalFont
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        if isEnabled {
            backgroundColor = normalBackgroundColor
            layer.borderColor = normalBorderColor.cgColor
            setTitleColor(normalFontColor, for: .normal)
            imageView?.tintColor = normalFontColor
        } else {
            backgroundColor = disabledBackgroundColor
            layer.borderColor = disabledBorderColor.cgColor
            setTitleColor(disabledFontColor, for: .disabled)
            imageView?.tintColor = disabledFontColor
        }
    }

    override open func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var titleRect = super.titleRect(forContentRect: contentRect)
        let imageRect = super.imageRect(forContentRect: contentRect)

        let buttonHasImage = !imageRect.isEmpty
        guard buttonHasImage else { return titleRect }

        switch imageAlignment {
        case .left: titleRect.origin.x += contentEdgeInsets.left / 2.0
        case .right: titleRect.origin.x = imageRect.origin.x - contentEdgeInsets.right / 2.0
        case .regular: titleRect.origin.x = contentEdgeInsets.left
        }

        return titleRect
    }

    override open func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var imageRect = super.imageRect(forContentRect: contentRect)
        let titleRect = super.titleRect(forContentRect: contentRect)

        let buttonHasImage = !imageRect.isEmpty
        guard buttonHasImage else { return imageRect }

        switch imageAlignment {
        case .left: imageRect.origin.x -= contentEdgeInsets.left / 2.0
        case .right: imageRect.origin.x = titleRect.origin.x + titleRect.width - imageRect.width + contentEdgeInsets.right / 2.0
        case .regular:
            imageRect.origin.x = bounds.width - imageRect.size.width - contentEdgeInsets.right
            imageRect.origin.y = (bounds.height / 2) - 12
            imageRect.size.height = 24
        }
        return imageRect
    }
}

public extension BigButton {

    enum Style {
        case normal
        case primary
        case link

        // Using ".center" here is useful in order to just display the image as is without any scaling
        // All other modes will scale the image down to the height of the text
        case linkWithBorders

        case linkExternal
        case welcome
        case welcomeInverted
    }

    enum ImageScaling {
        case none // Just draws the image in the size provided without any scaling
        case matchTitleTextHeight // Scales the image to the title height while keeping the image aspect
    }
}

extension BigButton {
    enum Alignment {
        case left
        case right
        case regular
    }
}
