//
//  LearningCardOptionsSwitch.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 18.05.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common

import UIKit

class LearningCardOptionsSwitch: UIView {

    lazy var horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 24
        stack.isLayoutMarginsRelativeArrangement = true

        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 24, bottom: 14, trailing: 24)
        return stack
    }()

    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    lazy var toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = .backgroundAccent
        return toggle
    }()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
        setupConstraints()
    }

    func set(title: String, subtitle: String, isOn: Bool) {
        titleLabel.attributedText = NSAttributedString(string: title, attributes: ThemeManager.currentTheme.learningCardOptionsSwitchTitleAttributes)
        subtitleLabel.attributedText = NSAttributedString(string: subtitle, attributes: ThemeManager.currentTheme.learningCardOptionsSwitchSubtitleAttributes)
        toggle.setOn(isOn, animated: false)
    }

    func setupConstraints() {
        addSubview(horizontalStackView)
        horizontalStackView.constrainEdges(to: self)
        horizontalStackView.addArrangedSubview(verticalStackView)

        let switchContainer = UIView()
        horizontalStackView.addArrangedSubview(switchContainer)
        switchContainer.addSubview(toggle)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            toggle.leadingAnchor.constraint(equalTo: switchContainer.leadingAnchor),
            toggle.trailingAnchor.constraint(equalTo: switchContainer.trailingAnchor),
            toggle.centerYAnchor.constraint(equalTo: switchContainer.centerYAnchor)
        ])

        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 300), for: .vertical)
        toggle.setContentHuggingPriority(UILayoutPriority(rawValue: 300), for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
    }
}
