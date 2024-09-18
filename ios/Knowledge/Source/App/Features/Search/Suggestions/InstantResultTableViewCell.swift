//
//  InstantResultTableViewCell.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 06.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit

final class InstantResultTableViewCell: UITableViewCell {

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

    func set(suggestion: NSAttributedString, type: InstantResultViewItem.Kind) {

        if case .article = type {
           imageView?.image = Asset.article.image
        } else {
            imageView?.image = Asset.Icon.pillIcon.image
        }
        tintColor = ThemeManager.currentTheme.searchSuggestionsListTextColor
        accessoryView = UIImageView(image: Asset.Icon.arrowRight.image)
        accessoryView?.tintColor = ThemeManager.currentTheme.searchSuggestionsListAccessoryColor
        textLabel?.attributedText = suggestion
    }
}
