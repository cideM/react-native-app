//
//  TableViewFooterView.swift
//  Common
//
//  Created by CSH on 06.02.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

public class TableViewFooterView: UITableViewHeaderFooterView {

    private let label = UILabel()

    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.constrainEdges(to: layoutMarginsGuide)
    }

    public func set(text: String) {
        label.attributedText = NSMutableAttributedString(string: text, attributes: ThemeManager.currentTheme.footerViewTextAttributes)
    }

}
