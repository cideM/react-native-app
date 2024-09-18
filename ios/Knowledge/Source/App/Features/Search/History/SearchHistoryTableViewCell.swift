//
//  SearchHistoryTableViewCell.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 01.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import DesignSystem

final class SearchHistoryTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        selectionStyle = .none
        textLabel?.numberOfLines = 0
    }

    func set(historyItem: String, image: UIImage = Asset.Icon.searchHistory.image) {
        imageView?.image = image
        imageView?.tintColor = .iconTertiary
        textLabel?.attributedText = NSAttributedString(string: historyItem, attributes: ThemeManager.currentTheme.searchHistoryTableViewCellTextAttributes)
    }
}
