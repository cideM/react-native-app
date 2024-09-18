//
//  FactSheetSectionHeader.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 30.07.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization
import DesignSystem

class SimpleSectionHeader: UICollectionReusableView {

    static let reuseIdentifier: String = "SimpleSectionHeader"

    private let backgroundColorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
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
        titleLabel.text = nil
        titleLabel.attributedText = nil
        titleLabel.backgroundColor = .backgroundPrimary
    }

    func setTitle(_ title: String, isHighlighted: Bool) {
        titleLabel.attributedText = .init(string: title, attributes: .attributes(style: .paragraphBold))
        titleLabel.backgroundColor = isHighlighted ? .backgroundTextHighlightPrimary : .backgroundPrimary
    }
}

private extension SimpleSectionHeader {

    func commonInit() {

        // Make sure view looks good in landscape
        // by clipping the background to the safe area ...
        // backgroundColor = .backgroundPrimary
        // addSubview(backgroundColorView)
        // backgroundColorView.constrainEdges(to: safeAreaLayoutGuide)

        backgroundColor = .backgroundPrimary

        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}
