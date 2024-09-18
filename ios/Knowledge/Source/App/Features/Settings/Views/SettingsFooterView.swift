//
//  FooterView.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 23.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

final class SettingsFooterView: UITableViewHeaderFooterView {
    private let logoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = Common.Asset.logoAndNameHorizontal.image
        return view
    }()
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = Font.regular.font(withSize: 17)
        label.textColor = .textTertiary
        return label
    }()
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalCentering
        view.alignment = .center
        return view
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}

private extension SettingsFooterView {

    func commonInit() {
        versionLabel.text = L10n.SettingsFooter.Version.format(Application.main.version ?? "", Application.main.buildVersion ?? "")
        logoImageView.heightAnchor.constraint(equalToConstant: 16.0).isActive = true

        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(versionLabel)
        addSubview(stackView)
        setStackViewConstraints()
    }

    func setStackViewConstraints() {
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
    }
}
