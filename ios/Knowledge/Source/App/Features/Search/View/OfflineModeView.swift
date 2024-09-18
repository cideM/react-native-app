//
//  OfflineModeView.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 12.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

public final class OfflineModeView: UIView {

    private var action: (() -> Void)?

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.backgroundColor = ThemeManager.currentTheme.offlineModeLabelBackgroundColor
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        let line = NSMutableAttributedString(string: L10n.Search.OnlineSearchFailure.firstMessage, attributes: ThemeManager.currentTheme.offlineModeFirstTextAttributes)
        let secondLine = NSAttributedString(string: L10n.Search.OnlineSearchFailure.secondMessage, attributes: ThemeManager.currentTheme.offlineModeSecondTextAttributes)
        line.append(NSAttributedString(string: "\n"))
        line.append(secondLine)
        label.attributedText = line
        let tapGestureRecoginzer = UITapGestureRecognizer(target: self, action: #selector(labelWasTapped))
        label.addGestureRecognizer(tapGestureRecoginzer)
        label.isUserInteractionEnabled = true

        return label
    }()

    public init() {
        super.init(frame: .zero)

        backgroundColor = .canvas
        heightAnchor.constraint(equalToConstant: 74).isActive = true
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func labelWasTapped() {
        action?()
    }

    public func setAction(_ action: (() -> Void)?) {
        self.action = action
    }
}
