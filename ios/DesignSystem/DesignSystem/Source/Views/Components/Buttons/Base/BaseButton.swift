//
//  PrimaryButton.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 02.06.23.
//

import UIKit

public class BaseButton: UIButton {

    // If type `activityIndicator` is selected it will start showing the indicator after the
    // isEnabled property is set to false. It will be hidden if isEnabled is set to true.
    public enum IconType: Equatable {
        case none
        case activityIndicator
        case informational
        case feedback
        case list
    }

    // MARK: - Public
    public var title: String = "" {
        didSet {
            setAttributedTitleFrom(title: title, textColor: normalTextColor())
        }
    }

    public var iconType: IconType = .none {
        didSet {
            applyIconStyle()
        }
    }

    // MARK: - Initialization
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public convenience init() {
        self.init(type: .custom)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        applyCornerRadius()
        compose()
        applyBackgroundColorForStates()
    }

    // MARK: - Private
    private var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var iconImageViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .medium
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var textLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var labelContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var titleStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        view.spacing = .spacing.xxs
        view.isUserInteractionEnabled = false
        return view
    }()

    private func applyCornerRadius() {
        apply(cornerRadius: .radius.xs)
    }

    private func compose() {

        iconImageViewContainer.addSubview(iconImageView)
        iconImageView.pin(to: iconImageViewContainer)
        titleStackView.addArrangedSubview(iconImageViewContainer)

        titleStackView.addArrangedSubview(activityIndicatorView)

        titleStackView.addArrangedSubview(textLabel)

        addSubview(titleStackView)
        titleStackView.center(in: self)

        iconImageView.tintColor = normalTextColor()
        activityIndicatorView.color = disabledTextColor()

        constrainHeight(.h48)
    }

    private func applyIconStyle() {
        switch iconType {
        case .informational:
            iconImageView.image = Asset.Icon.info.image
        case .feedback:
            iconImageView.image = Asset.Icon.feedback.image
        case .list:
            iconImageView.image = Asset.Icon.list.image
        default:
            iconImageView.image = nil
        }
    }

    // MARK: - Overrides
    override public var isHighlighted: Bool {
        didSet {
            let color = isHighlighted ? highlightedTextColor() : normalTextColor()
            setAttributedTitleFrom(title: title, textColor: color)
            iconImageView.tintColor = color
        }
    }

    override public var isEnabled: Bool {
        didSet {
            let color = isEnabled ? normalTextColor() : disabledTextColor()
            setAttributedTitleFrom(title: title, textColor: color)
            iconImageView.tintColor = color

            if isEnabled == false && iconType == .activityIndicator {
                activityIndicatorView.isHidden = false
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.isHidden = true
                activityIndicatorView.stopAnimating()
            }
        }
    }

    // MARK: - Open Functions
    internal func applyBackgroundColorForStates() {}

    internal func normalTextColor() -> UIColor {
        .backgroundAccent
    }

    internal func textStyle() -> TextStyle {
        .paragraphBold
    }

    internal func highlightedTextColor() -> UIColor {
        .backgroundAccent
    }

    internal func disabledTextColor() -> UIColor {
        .backgroundAccent
    }

    // MARK: - TraitCollectionChange
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyBackgroundColorForStates()
    }

    // MARK: - Private
    private func setAttributedTitleFrom(title: String, textColor: UIColor) {
        textLabel.attributedText = .attributedString(with: title,
                                                     style: textStyle(),
                                                     decorations: [.color(textColor), .alignment(.center)])
    }
}
