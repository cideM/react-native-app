//
//  ColorThemeAwareUITableViewCell.swift
//  Knowledge
//
//  Created by Elmar Tampe on 07.09.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit
import DesignSystem

public class ColorThemeAwareUITableViewCell: UITableViewCell {

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
}
