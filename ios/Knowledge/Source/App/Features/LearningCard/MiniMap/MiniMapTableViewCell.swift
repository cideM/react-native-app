//
//  MiniMapTableViewCell.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 02.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

final class MiniMapTableViewCell: UITableViewCell {

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
    }

    func set(title: NSMutableAttributedString, image: UIImage? = nil) {
        textLabel?.attributedText = title
        imageView?.image = image
    }
}
