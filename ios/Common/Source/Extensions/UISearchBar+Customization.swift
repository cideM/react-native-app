//
//  UISearchBar+Customization.swift
//  Common
//
//  Created by Silvio Bulla on 26.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

public extension UISearchBar {

    func styled(with placeholder: NSAttributedString, image: UIImage, backgroundColor: UIColor, tintColor: UIColor, barTintColor: UIColor, imageTintColor: UIColor = ThemeManager.currentTheme.searchTextFieldIconTintColor) {
        guard let backgroundView = searchTextField.subviews.first else { return }

        searchBarStyle = .minimal
        self.tintColor = tintColor
        self.barTintColor = barTintColor
        searchTextField.backgroundColor = backgroundColor
        setPositionAdjustment(UIOffset(horizontal: 6, vertical: 0), for: .search)
        backgroundView.backgroundColor = backgroundColor
        backgroundView.layer.cornerRadius = 10
        backgroundView.clipsToBounds = true
        backgroundView.subviews.forEach { $0.removeFromSuperview() }

        searchTextField.tintColor = ThemeManager.currentTheme.searchTextFieldTintColor
        searchTextField.attributedPlaceholder = placeholder

        let iconView = UIImageView(frame: .zero)
        iconView.contentMode = .scaleAspectFit
        iconView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iconView.image = image.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = imageTintColor
        searchTextField.leftView = iconView
    }
}
