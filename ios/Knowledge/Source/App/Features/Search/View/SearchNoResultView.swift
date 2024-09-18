//
//  SearchNoResultView.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 07.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

public final class SearchNoResultView: UIView {

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 16
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = NSAttributedString(string: L10n.Search.SearchScope.Overview.NoResultsView.title, attributes: ThemeManager.currentTheme.searchNoResultsViewTitleTextAttributes)
        return label
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = NSAttributedString(string: L10n.Search.SearchScope.Overview.NoResultsView.subtitle, attributes: ThemeManager.currentTheme.searchNoResultsViewSubtitleTextAttributes)
        return label
    }()

    private let button: BigButton = {
        let button = BigButton()
        button.setTitle(L10n.Search.SearchScope.Overview.NoResultsView.Button.title, for: .normal)
        button.style = .primary
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }()

    public init(buttonAction: @escaping () -> Void) {
        super.init(frame: .zero)

        backgroundColor = .canvas
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(label)
        stackView.setCustomSpacing(24, after: label)
        stackView.addArrangedSubview(button)
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50)
        ])

        button.touchUpInsideActionClosure = buttonAction
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
