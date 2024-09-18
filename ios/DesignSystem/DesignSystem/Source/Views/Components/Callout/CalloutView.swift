//
//  CalloutView.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 21.11.23.
//

import UIKit

public class CalloutView: UIView {

    // MARK: - View Data
    public struct ViewData {
        public let calloutType: CalloutType
        public let attributedTitle: NSAttributedString?
        public let attributedDescription: NSAttributedString

        public init(title: String? = nil,
                    description: String,
                    calloutType: CalloutType) {
            self.calloutType = calloutType
            if let title = title {
                self.attributedTitle = .attributedString(
                    with: title,
                    style: .paragraphSmallBold)
                .with(.byTruncatingTail)
            } else {
                self.attributedTitle = nil
            }
            self.attributedDescription = .attributedString(
                with: description,
                style: .paragraphSmall)
            .with(.byTruncatingTail)
        }

        public init(attributedTitle: NSAttributedString? = nil,
                    attributedDescription: NSAttributedString,
                    calloutType: CalloutType) {
            self.calloutType = calloutType
            self.attributedTitle = attributedTitle?.with(.byTruncatingTail)
            self.attributedDescription = attributedDescription.with(.byTruncatingTail)
        }
    }

    // MARK: - Public
    public enum CalloutType {
        case informational
        case success
        case error
        case warning
    }

    public var viewData: ViewData? {
        didSet {
            applyComponentStyle()
            applyTextStyle()
        }
    }

    // MARK: - Initialization
    override public init(frame: CGRect) {
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Init
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        apply(cornerRadius: .radius.xs)
        compose()
    }

    // MARK: - Private
    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        return view
    }()

    // MARK: - Private
    private let textStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    private let iconImageViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let image = Asset.Icon.info.image
        view.image = image
        view.constrainSize(image.size)
        return view
    }()

    private let titleLabelViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let descriptionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Composition
    private func compose() {
        addSubview(mainStackView)
        mainStackView.pin(to: self, insets: .init(all: .spacing.m))

        iconImageViewContainer.addSubview(iconImageView)
        iconImageView.pinTop(to: iconImageViewContainer, insets: .init(top: 2.0, left: 0, bottom: 0, right: 0))

        mainStackView.addArrangedSubview(iconImageViewContainer)

        titleLabelViewContainer.addSubview(titleLabel)
        titleLabel.pinLeft(to: titleLabelViewContainer, insets: .init(top: 0.0, left: 0, bottom: 0, right: 0))

        textStackView.addArrangedSubview(titleLabelViewContainer)
        textStackView.addArrangedSubview(descriptionLabel)
        mainStackView.addArrangedSubview(textStackView)

        mainStackView.setCustomSpacing(.spacing.xs, after: iconImageViewContainer)
        mainStackView.setCustomSpacing(.spacing.xxs, after: titleLabel)
    }

    private func applyComponentStyle() {
        var calloutColor: UIColor = .clear
        var iconColor: UIColor = .clear
        var image = Asset.Icon.info.image

        switch viewData?.calloutType {
        case .informational:
            calloutColor = .backgroundInfoSubtle
            iconColor = .iconInfo
        case .success:
            calloutColor = .backgroundSuccessSubtle
            iconColor = .iconSuccess
            image = Asset.Icon.checkmarkCircle.image
        case .error:
            calloutColor = .backgroundErrorSubtle
            iconColor = .iconError
        case .warning:
            calloutColor = .backgroundWarningSubtle
            iconColor = .iconWarning
        case .none:
            break
        }

        backgroundColor = calloutColor
        iconImageView.image = image
        iconImageView.tintColor = iconColor
    }

    private func applyTextStyle() {
        let color = fontColorForType(calloutType: viewData?.calloutType ?? .informational)
        titleLabel.attributedText = nil
        descriptionLabel.attributedText = nil

        if let attributedTitle = viewData?.attributedTitle {
            titleLabel.attributedText = attributedTitle.with([.color(color), .alignment(.left)])

        }

        if let attributedDescription = viewData?.attributedDescription {
            descriptionLabel.attributedText = attributedDescription.with([.color(color), .alignment(.left)])
        }
    }

    // MARK: - Helper
    private func fontColorForType(calloutType: CalloutType) -> UIColor {
        switch calloutType {
        case .informational:
            return .textInfo
        case .success:
            return .textSuccess
        case .error:
            return .textError
        case .warning:
            return .textWarning
        }
    }
}
