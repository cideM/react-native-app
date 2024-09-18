//
//  SearchSuggestionTableViewCell.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 30.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit

final class AutocompleteTableViewCell: UITableViewCell {

    static let titleStyle: HTMLParser.Attributes = {
        HTMLParser.Attributes(
            normal: ThemeManager.currentTheme.searchSuggestionItemNormalTitleTextAttributes,
            bold: ThemeManager.currentTheme.searchSuggestionItemBoldTitleTextAttributes,
            italic: ThemeManager.currentTheme.searchSuggestionItemItalicTitleTextAttributes
        )
    }()

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

    func set(suggestion: NSAttributedString, image: UIImage? = Asset.Icon.midiSearch.image) {
        imageView?.image = image
        tintColor = ThemeManager.currentTheme.searchSuggestionsListTextColor
        textLabel?.attributedText = suggestion
    }
}
