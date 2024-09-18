//
//  LibraryTreeFolderTableViewCell.swift
//  Knowledge
//
//  Created by Silvio Bulla on 29.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

final class LibraryTreeFolderTableViewCell: UITableViewCell {

    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private weak var childCountLabel: UILabel!
    @IBOutlet private weak var leftImageView: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .backgroundPrimary
    }

    func configure(title: String, childCount: Int?) {
        leftImageView.tintColor = .iconQuaternary
        titleLabel.attributedText = NSAttributedString(string: title, attributes: ThemeManager.currentTheme.libraryViewTitleLabelTextAttributes)
        if let childCount = childCount {
            childCountLabel.attributedText = childCount > 0 ? NSAttributedString(string: "(\(childCount))", attributes: ThemeManager.currentTheme.libraryViewChildCountLabelTextAttributes) : NSAttributedString(string: "")
        }
    }
}
