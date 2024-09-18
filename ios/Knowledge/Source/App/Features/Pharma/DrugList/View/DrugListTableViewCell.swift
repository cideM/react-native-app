//
//  DrugListTableViewCell.swift
//  Knowledge DE
//
//  Created by Merve Kavaklioglu on 11.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

class DrugListTableViewCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var vendorLabel: UILabel!
    @IBOutlet private weak var atcLabel: UILabel!
    @IBOutlet private weak var applicationFormsLabel: UILabel!
    @IBOutlet private weak var priceAndPackageSizeLabel: UILabel!

    func configure(item: DrugReferenceViewData) {

        nameLabel.attributedText = NSAttributedString(string: item.name.uppercased(), attributes: .attributes(style: .h5))

        let attributes: [NSAttributedString.Key: Any] = .attributes(style: .paragraph, with: [.color(.textSecondary)])
        vendorLabel.attributedText = NSAttributedString(string: item.vendor, attributes: attributes)
        atcLabel.attributedText = NSAttributedString(string: item.atc, attributes: attributes)
        applicationFormsLabel.attributedText = NSAttributedString(string: item.applicationForms, attributes: attributes)
        priceAndPackageSizeLabel.attributedText = NSAttributedString(string: item.priceAndPackageSize, attributes: attributes)
    }
}
