//
//  IAPBannerView.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 18.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import Foundation
import UIKit

public final class IAPBannerView: UIStackView {

    private var action: (() -> Void)?

    private let seperatorView: UIView = {
        let seperatorView = UIView()
        seperatorView.backgroundColor = ThemeManager.currentTheme.iAPBannerSeparatorColor

        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            seperatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        return seperatorView
    }()

    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 15
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.distribution = .fillProportionally
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 23, bottom: 14, right: 23)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .white
        return stack
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 2
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.ambossLogo.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.attributedText = NSAttributedString(string: L10n.Dashboard.IapBanner.title, attributes: ThemeManager.currentTheme.iAPBannerViewTitleTextAttributes)
        return label
    }()

    private let subtitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.attributedText = NSAttributedString(string: L10n.Dashboard.IapBanner.subTitle, attributes: ThemeManager.currentTheme.iAPBannerViewSubtitleTextAttributes)
        return label
    }()

    // This is here because stackviews on iOS13 cant have a background color
    private let backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        return layer
    }()

    public init(buttonAction: @escaping () -> Void) {
        super.init(frame: .zero)

        layer.addSublayer(backgroundLayer)

        axis = .vertical
        translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(subtitle)

        mainStackView.addArrangedSubview(logoImageView)
        mainStackView.addArrangedSubview(stackView)
        addArrangedSubview(mainStackView)
        addArrangedSubview(seperatorView)

        let tapGestureRecoginzer = UITapGestureRecognizer(target: self, action: #selector(labelWasTapped))
        addGestureRecognizer(tapGestureRecoginzer)

        self.action = buttonAction
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = layer.bounds
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func labelWasTapped() {
        action?()
    }
}
