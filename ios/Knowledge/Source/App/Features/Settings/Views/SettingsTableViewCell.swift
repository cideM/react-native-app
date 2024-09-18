//
//  NonSelectableTableViewCell.swift
//  Common
//
//  Created by Aamir Suhial Mir on 23.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common

import UIKit

final class SettingsTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        selectionStyle = .none
        backgroundColor = .backgroundPrimary
        guard
            let textLabel = self.textLabel,
            let detailTextLabel = self.detailTextLabel else {
                preconditionFailure()
        }

        textLabel.font = Font.medium.font(withSize: 17)
        textLabel.textColor = .textSecondary
        textLabel.numberOfLines = 0

        detailTextLabel.font = Font.regular.font(withSize: 14)
        detailTextLabel.textColor = .textSecondary
    }

    func configure(with item: Settings.Item) {
        textLabel?.text = item.title
        if item.subtitleWarning {
            detailTextLabel?.attributedText = NSAttributedString(string: item.subtitle, attributes: ThemeManager.currentTheme.settingsDestructiveButtonTextAttributes)
        } else {
            detailTextLabel?.attributedText = NSAttributedString(string: item.subtitle, attributes: ThemeManager.currentTheme.settingsSubtitleLabelTextAttributes)
        }
        accessoryType = item.hasChevron ? .disclosureIndicator : .none
    }
}
