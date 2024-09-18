//
//  TagButton+Filters.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 26.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain
import UIKit

extension TagButton {

    static func styled(for filter: SearchFilterViewItem) -> TagButton {
        let button = TagButton()
        button.setBackgroundColor(ThemeManager.currentTheme.searchFiltersTagNormalBackgroundColor, for: .normal)
        button.setBorderColor(ThemeManager.currentTheme.searchFiltersTagNormalBorderColor, for: .normal)
        button.setBackgroundColor(ThemeManager.currentTheme.searchFiltersTagSelectedBackgroundColor, for: .selected)
        button.setBorderColor(ThemeManager.currentTheme.searchFiltersTagSelectedBorderColor, for: .selected)
        return button
    }

    func setTitle(with data: SearchFilterViewItem) {
        let theme = ThemeManager.currentTheme

        let label = "\(data.name) (\(data.count))"
        let normalTitle = NSMutableAttributedString(string: label, attributes: theme.searchFiltersTagNormalTextAttributes)
        let selectedTitle = NSMutableAttributedString(string: label, attributes: theme.searchFiltersTagSelectedTextAttributes)

        setAttributedTitle(normalTitle, for: .normal)
        setAttributedTitle(selectedTitle, for: .selected)
    }
}
