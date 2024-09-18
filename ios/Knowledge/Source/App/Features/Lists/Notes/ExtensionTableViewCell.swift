//
//  ExtensionTableViewCell.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 20.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

final class ExtensionTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var learningCardButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        learningCardButton.setAttributedTitle(NSAttributedString(string: L10n.ExtensionCellView.Button.title,
                                                                 attributes: ThemeManager.currentTheme.extensionCellButtonTextAttributes),
                                              for: .normal)
        learningCardButton.imageView?.tintColor = .iconTertiary
        textView.textContainer.maximumNumberOfLines = 30
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.textColor = .textSecondary
        backgroundColor = .backgroundPrimary
    }

    func configure(title: String?, notes: String?) {
        if let title = title {
            titleLabel.attributedText = NSAttributedString(string: "In \(title)",
                                                           attributes: ThemeManager.currentTheme.extensionCellTitleTextAttributes)
        }
        textView.text = notes ?? ""
    }
}
