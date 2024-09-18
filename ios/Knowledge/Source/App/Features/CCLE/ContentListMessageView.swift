//
//  ContentListMessageView.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 30.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

protocol ContentListMessageViewDelegate: AnyObject {
    func didTapActionButton()
}

final class ContentListMessageView: UIView {
    private lazy var messageTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var messageSubtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let actionButton: BigButton = {
        let button = BigButton()
        button.style = .primary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var delegate: ContentListMessageViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubview(messageTitleLabel)
        addSubview(messageSubtitleLabel)
        addSubview(actionButton)

        NSLayoutConstraint.activate([
            messageTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            messageTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageTitleLabel.bottomAnchor.constraint(equalTo: messageSubtitleLabel.topAnchor, constant: -4),

            messageSubtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageSubtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageSubtitleLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -16),

            actionButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -40),
            actionButton.heightAnchor.constraint(equalToConstant: 40),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 106),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }

    func configure(title: String, subtitle: String, actionTitle: String? = nil) {
        messageTitleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: ThemeManager.currentTheme.contentListMessageTitleAttributes)
        messageSubtitleLabel.attributedText = NSAttributedString(
            string: subtitle,
            attributes: ThemeManager.currentTheme.contentListMessageSubtitleAttributes)
        actionButton.setAttributedTitle(NSAttributedString(
            string: actionTitle ?? "",
            attributes: ThemeManager.currentTheme.contentListMessageButtonTitleAttributes),
                                        for: .normal)

        actionButton.isHidden = actionTitle == nil

    }

    @objc func didTapActionButton() {
        self.delegate?.didTapActionButton()
    }
}
