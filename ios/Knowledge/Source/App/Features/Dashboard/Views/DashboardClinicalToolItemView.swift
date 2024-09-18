//
//  DashboardClinicalToolItemView.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 21.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Common
import DesignSystem

final class DashboardClinicalToolItemView: UIView {

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .iconTertiary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titlesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let badge: BadgeView = {
        let view = BadgeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let badgeContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let subtitleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let additionalIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var additionalIconWidthConstraint: NSLayoutConstraint?
    private var additionalIconHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .backgroundPrimary
        self.addSubview(stackView)
        stackView.constrain(to: self, margins: UIEdgeInsets(top: 12, left: 16, bottom: -12, right: -16))
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titlesStackView)
        titlesStackView.addArrangedSubview(titleLabel)
        titlesStackView.addArrangedSubview(subtitleStackView)
        subtitleStackView.addArrangedSubview(subtitleLabel)
        subtitleStackView.addArrangedSubview(additionalIconImageView)
        subtitleStackView.addArrangedSubview(UIView())
        stackView.setCustomSpacing(.spacing.xs, after: titlesStackView)
        stackView.addArrangedSubview(badgeContainer)
        badgeContainer.addSubview(badge)
        badge.centerVerticallyAndPinHorizontally(in: badgeContainer)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(countLabel)

        countLabel.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            subtitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 62)
        ])
    }

    func configure(clinicalTool: ClinicalTool) {
        self.titleLabel.attributedText = NSAttributedString(string: clinicalTool.title, attributes: ThemeManager.currentTheme.dashboardClinicalToolsTitleTextAttributes)
        self.subtitleLabel.attributedText = NSAttributedString(string: clinicalTool.subtitle ?? "", attributes: ThemeManager.currentTheme.dashboardClinicalToolsSubtitleTextAttributes)
        self.subtitleStackView.isHidden = clinicalTool.subtitle == nil

        self.countLabel.attributedText = NSAttributedString(string: "(\(String(describing: clinicalTool.contentCount)))", attributes: ThemeManager.currentTheme.dashboardClinicalToolsCountTextAttributes)
        self.iconImageView.image = clinicalTool.icon
        self.additionalIconImageView.image = clinicalTool.additionalIcon
        self.additionalIconImageView.isHidden = clinicalTool.additionalIcon == nil
        self.badge.isHidden = clinicalTool.badgeTitle == nil

        if let badgeTitle = clinicalTool.badgeTitle {
            self.badge.configure(text: badgeTitle)
        }

        if let size = clinicalTool.additionalIconSize {
            setAdditionalIconSize(size)
        }
    }

    private func setAdditionalIconSize(_ size: CGSize) {
        if additionalIconWidthConstraint != nil && additionalIconHeightConstraint != nil {
            additionalIconWidthConstraint?.constant = size.width
            additionalIconHeightConstraint?.constant = size.height
        } else {

            let widthConstraint = additionalIconImageView.widthAnchor.constraint(equalToConstant: size.width)
            let heightConstraint = additionalIconImageView.heightAnchor.constraint(equalToConstant: size.height)

            NSLayoutConstraint.activate([
                widthConstraint,
                heightConstraint
            ])
            additionalIconWidthConstraint = widthConstraint
            additionalIconHeightConstraint = heightConstraint
        }
    }
}
