//
//  SectionSettingsHeaderView.swift
//  Knowledge
//
//  Created by Elmar Tampe on 22.09.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit
import DesignSystem

public class SettingsSectionHeaderView: UITableViewHeaderFooterView {

    // MARK: - Public
    static let reuseIdentifier = String(describing: SettingsSectionHeaderView.self)

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialisation
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: Self.reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Common Init
    private func commonInit() {
        contentView.backgroundColor = .canvas
        contentView.addSubview(titleLabel)
        titleLabel.pin(to: contentView, insets: .init(top: 8.0, left: 20.0, bottom: 8.0, right: 8.0))
    }
}
