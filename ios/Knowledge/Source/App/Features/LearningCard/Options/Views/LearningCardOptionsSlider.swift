//
//  LearningCardOptionsSlider.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 18.05.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common

import UIKit

class LearningCardOptionsSlider: UIView {

    lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundPrimary
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        return stack
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .backgroundAccent
        slider.maximumTrackTintColor = .backgroundTransparentSelected
        return slider
    }()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
        setupConstraints()
    }

    func set(title: String, minValue: Float, maxValue: Float, value: Float) {
        slider.minimumValue = minValue
        slider.maximumValue = maxValue
        slider.value = value

        titleLabel.attributedText = NSAttributedString(string: title, attributes: ThemeManager.currentTheme.learningCardOptionsSwitchTitleAttributes)
    }

    func setupConstraints() {
        addSubview(backgroundView)
        backgroundView.addSubview(verticalStackView)
        verticalStackView.constrainEdges(to: backgroundView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(slider)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            backgroundView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            backgroundView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            backgroundView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
}
