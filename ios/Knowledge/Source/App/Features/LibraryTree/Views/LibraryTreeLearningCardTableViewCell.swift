//
//  LibraryTreeLearningCardTableViewCell.swift
//  Knowledge
//
//  Created by Silvio Bulla on 02.12.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit

final class LibraryTreeLearningCardTableViewCell: UITableViewCell {

    private let learningCardView: LibraryTreeLearningCardView = {
        let view = LibraryTreeLearningCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = ThemeManager.currentTheme.textBackgroundColor
        contentView.addSubview(learningCardView)
        learningCardView.constrain(to: contentView)
    }

    func configure(with title: String, isFavorite: Bool, isLearned: Bool) {
        learningCardView.configure(with: title, isFavorite: isFavorite, isLearned: isLearned)
    }
}

final class LibraryTreeLearningCardView: UIView {

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.learningCard.image
        imageView.tintColor = .iconQuaternary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.Icon.learned.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.Icon.favorite.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

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

        stackView.constrain(to: self, margins: UIEdgeInsets(top: 8, left: 18, bottom: -8, right: -18))
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(checkmarkImageView)
        stackView.addArrangedSubview(starImageView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 16),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 18),
            starImageView.widthAnchor.constraint(equalToConstant: 18)
        ])
    }

    func configure(with title: String, isFavorite: Bool, isLearned: Bool) {

        titleLabel.attributedText = NSAttributedString(string: title, attributes: ThemeManager.currentTheme.libraryViewTitleLabelTextAttributes)
        checkmarkImageView.isHidden = !isLearned
        starImageView.isHidden = !isFavorite
    }
}
