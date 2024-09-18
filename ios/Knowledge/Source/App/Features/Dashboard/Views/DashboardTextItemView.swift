//
//  DashboardTextItemView.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 16.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Common

final class DashboardTextItemView: UIView {

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
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

    private func commonInit() {
        backgroundColor = .backgroundPrimary

        self.addSubview(label)
        label.constrain(to: self, margins: UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16))
    }

    func configure(text: String) {
        self.label.attributedText = NSAttributedString(string: text, attributes: ThemeManager.currentTheme.recentsListEmptyStateTextAttributes)
    }
}
