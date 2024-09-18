//
//  AgentSectionTableViewHEader.swift
//  Knowledge
//
//  Created by Silvio Bulla on 22.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization
import DesignSystem

class PharmaSectionHeader: UICollectionReusableView {

    static let reuseIdentifier: String = "PharmaHeader"

    let backgroundColorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundPrimary
        return view
    }()

    let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Asset.Icon.pharmaExpandableSectionHeader.image
        imageView.tintColor = .iconTertiary
        return imageView
    }()

    let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.attributedText = NSAttributedString(
            string: L10n.Drug.SectionHeader.EmptyLabel.text,
            attributes: .attributes(style: .paragraph, with: [.color(.tertiaryLabel)]))
        label.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        label.isHidden = true
        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        arrowImageView.transform = .identity
        titleLabel.text = nil
        titleLabel.attributedText = nil
    }
}

private extension PharmaSectionHeader {

    func commonInit() {

        // Make sure view looks good in landscape
        // by clipping the background to the safe area ...
        backgroundColor = .backgroundPrimary
        addSubview(backgroundColorView)

        backgroundColorView.constrainEdges(to: safeAreaLayoutGuide)

        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emptyLabel)
        stackView.addArrangedSubview(arrowImageView)

        NSLayoutConstraint.activate([
            arrowImageView.widthAnchor.constraint(equalToConstant: 24),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
}
