//
//  DashboardHeaderView.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 20.12.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

/// Reasons for existence of this subclass:
/// * The system navar can not be made to look like in the design specs hence we fake this one
/// * The navbar needs to have two rows on iPad (buttons top, search below) - can not be done with system bar
/// * Easy setup of callback functions for the searchbar and stage button
class DashboardHeaderView: UIView {

    var didTapSearchBar: (() -> Void)?
    var didTapStageButton: (() -> Void)?

    private var button: DashboardPillButton?
    private(set) var searchBar: UISearchBar?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setTitle(_ title: String?) {
        assert(button != nil)
        button?.isHidden = title == nil
        guard let title = title else { return }
        let attributedTitle = NSAttributedString(string: title, attributes: ThemeManager.currentTheme.dashboardUserStageButtonTextAttributes)
        button?.setAttributedTitle(attributedTitle, for: .normal)
    }
}

private extension DashboardHeaderView {

    func setup() {

        clipsToBounds = false
        backgroundColor = .backgroundAccent
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 110)
        ])

        // Statusbar background ...

        let backgroundView = UIView(frame: .zero)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = backgroundColor
        addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: topAnchor),

            // Arbitrary large value to cover statusbar height
            // Querying safeAreaInsets does not work cause view might not yet be in hirarchy
            backgroundView.heightAnchor.constraint(equalToConstant: 200)
        ])

        // Logo ...

        let logoImageView = UIImageView(image: Common.Asset.logoAndNameHorizontalWhite.image)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit

        addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.heightAnchor.constraint(equalToConstant: 21),
            logoImageView.widthAnchor.constraint(equalToConstant: 126),
            topAnchor.constraint(equalTo: logoImageView.topAnchor, constant: -18),
            safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: logoImageView.leadingAnchor, constant: -16)
        ])

        // Pill button ...
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 6, trailing: 12)
        configuration.titleLineBreakMode = .byTruncatingTail
        let button = DashboardPillButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .backgroundPrimary
        button.tintColor = .iconAccent
        self.button = button

        let image = Asset.Icon.chevronRight.image
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .highlighted)
        button.semanticContentAttribute = .forceRightToLeft // <- image on right side

        button.touchUpInsideActionClosure = { [weak self] in
            self?.didTapStageButton?()
        }

        addSubview(button)
        NSLayoutConstraint.activate([
            safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 16),
            logoImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            button.leadingAnchor.constraint(greaterThanOrEqualTo: logoImageView.trailingAnchor, constant: 8)
        ])

        // Searchbar ...

        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        let attributedPlaceholder = NSAttributedString(string: L10n.Dashboard.HeaderView.searchPlaceholder,
                                                       attributes: ThemeManager.currentTheme.searchTextFieldPlaceholderTextAttributes)
        searchBar.styled(with: attributedPlaceholder,
                         image: Asset.Icon.search.image,
                         backgroundColor: .backgroundPrimary,
                         tintColor: .iconOnAccent,
                         barTintColor: .backgroundAccentSubtle,
                         imageTintColor: .iconSecondary)
        searchBar.delegate = self

        addSubview(searchBar)
        self.searchBar = searchBar
        NSLayoutConstraint.activate([
            safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: -8),
            safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 8),
            safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 6)
        ])
    }
}

extension DashboardHeaderView: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
         didTapSearchBar?()
         return false
     }
}
