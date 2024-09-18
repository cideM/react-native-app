//
//  PharmaFeedbackTableViewCell.swift
//  Knowledge DE
//
//  Created by Manaf Alabd Alrahim on 25.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

class PharmaFeedbackCell: UICollectionViewCell {

    weak var delegate: PharmaFeedbackCellDelegate?

    private lazy var feedbackButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(feedbackButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(string: L10n.Substance.FeedbackButton.title,
                                                     attributes: .attributes(style: .paragraphSmallBold)), for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    @objc func feedbackButtonTapped() {
        self.delegate?.sendFeedback()
    }
}

extension PharmaFeedbackCell {

    private func commonInit() {
        self.contentView.backgroundColor = ThemeManager.currentTheme.backgroundColor
        self.contentView.addSubview(self.feedbackButton)
        self.setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            feedbackButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            feedbackButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            feedbackButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            feedbackButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
