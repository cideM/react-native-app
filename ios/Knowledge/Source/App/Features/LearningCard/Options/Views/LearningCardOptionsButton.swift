//
//  LearningCardOptionsButton.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 18.05.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common

import UIKit

class LearningCardOptionsButton: UIView {

    lazy var horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 24)
        return stack
    }()

    lazy var button: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 8)
        configuration.imagePadding = 12
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(image: Asset.Icon.chevronRight.image)
        imageView.tintColor = .iconOnAccent
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
        setupConstraints()
    }

    func set(title: String, image: UIImage, hasChevron: Bool) {
        button.setAttributedTitle(NSAttributedString(string: title, attributes: ThemeManager.currentTheme.learningCardOptionsButtonTitleAttributes), for: .normal)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)

        self.chevronImageView.isHidden = !hasChevron
    }

    func setupConstraints() {
        addSubview(horizontalStackView)
        horizontalStackView.constrainEdges(to: self)
        horizontalStackView.addArrangedSubview(button)
        horizontalStackView.addArrangedSubview(chevronImageView)

        NSLayoutConstraint.activate([
            chevronImageView.widthAnchor.constraint(equalToConstant: 16)
        ])
    }
}
