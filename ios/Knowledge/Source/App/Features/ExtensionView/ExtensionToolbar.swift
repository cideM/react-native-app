//
//  ExtensionToolbar.swift
//  Knowledge
//
//  Created by Silvio Bulla on 09.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

class ExtensionToolbar: UIToolbar {

    let boldButton = button(with: Asset.Icon.bold.image)
    let italicButton = button(with: Asset.Icon.italic.image)
    let underlineButton = button(with: Asset.Icon.underline.image)
    let orderedListButton = button(with: Asset.Icon.orderedList.image)
    let unorderedListButton = button(with: Asset.Icon.unorderedList.image)
    let undoButton = button(with: Asset.Icon.undo.image)
    let redoButton = button(with: Asset.Icon.redo.image)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let buttons = [boldButton, italicButton, underlineButton, orderedListButton, unorderedListButton, undoButton, redoButton]
        var items = buttons.map { UIBarButtonItem(customView: $0) }
        items.insert(flexibleSpace, at: 0)
        items.append(flexibleSpace)
        setItems(items.arrayWithElementsSeparated(by: flexibleSpace), animated: true)
        tintColor = ThemeManager.currentTheme.tintColor
        self.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.setShadowImage(UIImage(), forToolbarPosition: .any)
    }

    private static func button(with image: UIImage, tintColor: UIColor = ThemeManager.currentTheme.tintColor) -> UIButton {
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = tintColor
        return button
    }
}
