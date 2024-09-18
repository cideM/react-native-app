//
//  TableViewHeaderView.swift
//  Common
//
//  Created by Maksim Tuzhilin on 24.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import UIKit

public class TableViewHeaderView: UITableViewHeaderFooterView {
    let titleLabel = UILabel()

    // MARK: - Layout
    class var contentMargins: UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 20)
    }

    class var defaultHeight: CGFloat {
        44.0
    }

    // MARK: - Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        contentView.layoutMargins = TableViewHeaderView.contentMargins

        // Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .textSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // Constraints
        let margins = contentView.layoutMarginsGuide
        titleLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

        contentView.backgroundColor = .canvas

        let border = UIView(frame: .zero)
        border.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(border)

        let borderWidth: CGFloat = 1
        border.heightAnchor.constraint(equalToConstant: borderWidth).isActive = true
        border.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        border.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        border.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        border.backgroundColor = ThemeManager.currentTheme.tableHeaderBorderColor

    }

    public func setTitle(_ text: String) {
        titleLabel.text = text
    }
}
