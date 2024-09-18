//
//  DashboardViewController.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 16.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization
import DesignSystem

/// @mockable
protocol DashboardViewType: AnyObject {
    func setSections(sections: [DashboardSection])
    func updateIAPBanner(title: String, subtitle: String, isHidden: Bool)
    func updateStageButton(with title: String?)
}

final class DashboardViewController: UIViewController {
    private let presenter: DashboardPresenterType

    let containerStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    lazy var header: DashboardHeaderView = {
        let header = DashboardHeaderView(frame: .zero)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.didTapSearchBar = { [weak self] in
            self?.presenter.didTapSearch()
        }
        header.didTapStageButton = { [weak self] in
            self?.presenter.didTapStageButton()
        }
        return header
    }()

    private lazy var contentView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.spacing = 16
        stack.axis = .vertical
        return stack
    }()

    private lazy var iAPBannerView: IAPBannerView = {
        let view = IAPBannerView(buttonAction: presenter.didTapIAPBanner)
        view.heightAnchor.constraint(equalToConstant: 76).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var scrollView: UIScrollView?

    init(presenter: DashboardPresenterType) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)

        title = L10n.Dashboard.title
        tabBarItem.image = Asset.Icon.dashboard.image
        navigationItem.largeTitleDisplayMode = .never
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // The `.styled` method is called twice because when the device is rotated, the UISearchBar loses its style.
        // This will be fixed by this ticket: https://miamed.atlassian.net/browse/SPG-574
        let attributedPlaceholder = NSAttributedString(string: L10n.Dashboard.HeaderView.searchPlaceholder,
                                                       attributes: ThemeManager.currentTheme.searchTextFieldPlaceholderTextAttributes)
        navigationItem.searchController?.searchBar.styled(with: attributedPlaceholder,
                                                          image: Asset.Icon.search.image,
                                                          backgroundColor: .backgroundAccentSubtle,
                                                          tintColor: .iconOnAccent,
                                                          barTintColor: .backgroundAccentSubtle)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        view.backgroundColor = ThemeManager.currentTheme.backgroundColor
        scrollView = setupScrollView()
        presenter.view = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()

        // No need for a navbar since we're using a fake one (DashboardHeaderView)
        // * This does nothing when a modal disappears (since navbar is already hidden)
        // * When popping a viewcontroller off the navstak this makes the disappearing controllers navbar animate out smoothly (the dashboard's navbar will already be hidden)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewWillDisappear()
        // We want the navbar on the presented viewcontroller ...
        let isModalPresentation = navigationController?.viewControllers.last === self
        if  isModalPresentation {
            // Modal presentation, do nothing ...
            // This works cause the new view just slides over
        } else {
            // New controller pushed on stack ...
            // This needs special treatment cause the real navbar of the presented controller is animated in
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}

extension DashboardViewController: DashboardViewType {

    func updateIAPBanner(title: String, subtitle: String, isHidden: Bool) {
        iAPBannerView.set(titleText: title, subtitleText: subtitle)

        // WORKAROUND:- Changed this from hiding/showing to removing/adding
        // because of unexpected layout issues that cause the screen to freeze.
        // There are too many breaking constraints already and this (possibly)
        // the tip-over point.
        if isHidden {
            iAPBannerView.removeFromSuperview()
        } else {
            containerStackView.insertArrangedSubview(iAPBannerView, at: 0)
        }

    }

    func setSections(sections: [DashboardSection]) {

        contentView.subviews.forEach { $0.removeFromSuperview() }

        for section in sections {
            switch section {
            case .clinicalTools(let viewData):
                addDashboardSection(viewData: viewData, style: .buttons)
            case .recents(let viewData):
                addDashboardSection(viewData: viewData, style: .list)
            case .highlights(let viewData):
                addDashboardSection(viewData: viewData, style: .singleCard)
            case .externalLink(let viewData):
                addDashboardSection(viewData: viewData, style: .singleCard)
            }
        }
    }

    func updateStageButton(with title: String?) {
        header.setTitle(title)
    }
}

private extension DashboardViewController {

    func setupScrollView() -> UIScrollView {

        view.addSubview(header)
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: header.topAnchor),
            view.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: header.trailingAnchor)
        ])

        view.addSubview(containerStackView)
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: header.bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .always
        containerStackView.addArrangedSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor)
        ])
        return scrollView
    }

    private func addDashboardSection(viewData: DashboardSectionViewData, style: DashboardSectionView.Style) {

        let sectionView = DashboardSectionView()
        sectionView.configure(with: viewData,
                              style: style,
                              contentCardViewDelegate: self,
                              linkCardViewDelegate: self)
        contentView.addArrangedSubview(sectionView)

        if viewData.hasSeparator {
            contentView.addArrangedSubview(createSeperatorView())
        }
    }

    private func createSectionStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.backgroundColor = ThemeManager.currentTheme.backgroundColor
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func createSeperatorView() -> UIView {
        let seperatorView = UIView()
        seperatorView.backgroundColor = ThemeManager.currentTheme.dashboardSectionSeparatorColor
        contentView.addArrangedSubview(seperatorView)

        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            seperatorView.heightAnchor.constraint(equalToConstant: 4)
        ])
        return seperatorView
    }
}

extension DashboardViewController: ContentCardViewDelegate {
    func didViewContentCard(at index: Int) {
        presenter.didViewContentCard(at: index)
    }

    func didTapContentCard(at index: Int) {
        presenter.didTapContentCard(at: index)
    }

    func didDismissContentCard(at index: Int) {
        presenter.didDismissContentCard(at: index)
    }

    func shouldOpenContentCardFeed() {
        presenter.shouldOpenContentCardFeed()
    }
}

extension DashboardViewController: LinkCardViewDelegate {
    func didTapLinkCard(_ card: LinkCardView) {
        guard let url = card.viewData?.url else { return }
        presenter.didTapLinkButton(url: url) {
            card.hideSpinner()
        }
    }
}
