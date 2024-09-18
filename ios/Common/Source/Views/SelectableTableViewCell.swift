//
//  SelectableTableViewCell.swift
//  Common
//
//  Created by CSH on 06.02.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

public class SelectableTableViewCell: UITableViewCell {

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = isSelected ? .checkmark : .none
    }

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
        textLabel?.numberOfLines = 0
        backgroundColor = .backgroundPrimary
    }

    public func set(title: String, titleAttributes: [NSAttributedString.Key: Any] = ThemeManager.currentTheme.selectableCellTitleTextAttributes, description: String? = nil) {
        textLabel?.attributedText = NSMutableAttributedString(string: title, attributes: titleAttributes)

        if let description = description {
            detailTextLabel?.attributedText = NSMutableAttributedString(string: description, attributes: ThemeManager.currentTheme.selectableCellDescriptionTextAttributes)
        }
    }
}
