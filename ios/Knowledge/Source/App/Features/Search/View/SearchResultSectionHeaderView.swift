//
//  SearchResultSectionHeaderView.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 31.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

final class SearchResultSectionHeaderView: UITableViewHeaderFooterView {
    private lazy var iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .iconQuaternary
        return iconImageView
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        return titleLabel
    }()

    private var informationImageView: UIImageView = {
        let informationImageView = UIImageView()
        informationImageView.contentMode = .scaleAspectFit
        return informationImageView
    }()

    private lazy var button = UIButton()

    private lazy var arrowImageView: UIImageView = {
        let arrowImage = Asset.Icon.historyNext.image
        let arrowImageView = UIImageView(image: arrowImage)
        arrowImageView.tintColor = ThemeManager.currentTheme.tintColor
        return arrowImageView
    }()

    private lazy var rightStackView: UIStackView = {
        let rightStackView = UIStackView()
        rightStackView.spacing = 8
        rightStackView.alignment = .center
        return rightStackView
    }()

    private lazy var leftStackView: UIStackView = {
        let leftStackView = UIStackView()
        leftStackView.spacing = 12
        leftStackView.alignment = .center
        return leftStackView
    }()

    // MARK: - Layout
    private var contentMargins: UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }

    static var defaultHeight: CGFloat {
        64.0
    }

    // MARK: - Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        contentView.layoutMargins = contentMargins
        contentView.backgroundColor = .canvas

        leftStackView.addArrangedSubview(iconImageView)
        leftStackView.addArrangedSubview(titleLabel)
        leftStackView.addArrangedSubview(informationImageView)

        rightStackView.addArrangedSubview(button)
        rightStackView.addArrangedSubview(arrowImageView)

        setupInformationImageViewConstraints()
        setupIconImageViewConstraints()
        setupArrowImageViewConstraints()

        contentView.addSubview(leftStackView)
        setupLeftStackViewConstraints()

        contentView.addSubview(rightStackView)
        setupRightStackViewConstraints()
    }

    private func setupIconImageViewConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }

    private func setupInformationImageViewConstraints() {
        informationImageView.translatesAutoresizingMaskIntoConstraints = false
        informationImageView.widthAnchor.constraint(equalToConstant: 52).isActive = true
        informationImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }

    private func setupLeftStackViewConstraints() {
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        leftStackView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        leftStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    private func setupRightStackViewConstraints() {
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        rightStackView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true
        rightStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    private func setupArrowImageViewConstraints() {
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        arrowImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }

    func configure(with searchResultHeaderData: SearchResultSection.SearchResultHeaderData) {
        iconImageView.image = searchResultHeaderData.iconImage.image
        titleLabel.attributedText = NSAttributedString(string: searchResultHeaderData.title, attributes: ThemeManager.currentTheme.searchResultTableViewHeaderTitleAttributes)
        informationImageView.image = searchResultHeaderData.informationImage?.image
        button.setAttributedTitle(NSAttributedString(string: searchResultHeaderData.buttonTitle, attributes: ThemeManager.currentTheme.searchResultTableViewHeaderButtonTitleAttributes), for: [])
        button.touchUpInsideActionClosure = searchResultHeaderData.buttonAction
    }
}
