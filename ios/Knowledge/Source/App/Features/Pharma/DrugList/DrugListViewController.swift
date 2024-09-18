//
//  DrugListViewController.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 10.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization
import DesignSystem

/// @mockable
final class DrugListViewController: UIViewController {

    private var presenter: DrugListPresenterType
    let searchController = UISearchController(searchResultsController: nil)

    /// Stored searched query.
    private var searchedQuery = String()
    /// Stored selected application form.
    private var selectedApplicationForm: ApplicationForm = .all
    private var applicationFormTagButtons: [TagButton] = []

    private lazy var loadingOverlayView: ActivityIndicatorView = {
        ActivityIndicatorView()
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    private let pillIndicator: UIView = {
        let pill = UIView()
        pill.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pill.widthAnchor.constraint(equalToConstant: 32),
            pill.heightAnchor.constraint(equalToConstant: 4)
        ])
        pill.backgroundColor = .tertiaryLabel
        pill.clipsToBounds = true
        pill.layer.cornerRadius = 2

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(pill)
        NSLayoutConstraint.activate([
            pill.topAnchor.constraint(equalTo: container.topAnchor, constant: Spacing.m),
            pill.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            container.heightAnchor.constraint(equalToConstant: Spacing.xxl)
        ])

        return container
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.attributedText = NSAttributedString(
            string: L10n.Drug.Search.firstTitle,
            attributes: .attributes(style: .paragraphBold, with: [.alignment(.left)]))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.transform = .init(translationX: 14, y: 0)
        return label
    }()

    private lazy var headerView: UIStackView = {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = .init(horizontal: 4, vertical: 0)
        view.spacing = Spacing.xs
        view.axis = .vertical
        return view
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = L10n.Drug.SearchBar.Placeholder.text
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .textAccent
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        return searchBar
    }()

    private lazy var tagsTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.attributedText = NSAttributedString(string: L10n.Drug.Search.tagsTitle, attributes:
                .attributes(style: .h6, with: [.color(.secondaryLabel)]))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.transform = .init(translationX: 8, y: 0)
        return label
    }()

    private lazy var applicationFormsTagsView: TilingContainerView = {
        let view = TilingContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInsets = .init(horizontal: Spacing.xs, vertical: Spacing.none)
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .backgroundPrimary
        tableView.estimatedRowHeight = 69
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UINib(nibName: DrugListTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: DrugListTableViewCell.reuseIdentifier)
        return tableView
    }()

    private var dataSource: DrugListDataSource?

    init(presenter: DrugListPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        setupView()
    }
}

// MARK: - Delegate Functions

extension DrugListViewController: DrugListViewType {

    func setApplicationForms(_ applicationForms: [TagButton.ViewData]) {
        applicationForms
            .forEach { data in
                let tagButton = TagButton.styled(for: data.applicationForm)
                tagButton.setTitle(with: data)

                // If there is one application form it will be selected by default. Otherwise ApplicationForm.all` is selected when view is presented.
                tagButton.isSelected = data.applicationForm == selectedApplicationForm
                if applicationForms.count == 1 {
                    tagButton.isSelected = true
                    tagButton.isUserInteractionEnabled = false
                }

                tagButton.touchUpInsideActionClosure = { [weak self] in
                    guard let self = self else { return }
                    guard data.applicationForm != self.selectedApplicationForm else { return }

                    self.selectedApplicationForm = data.applicationForm
                    self.applicationFormTagButtons.forEach { $0.isSelected = false }
                    self.applicationFormTouchUpInside(applicationForm: data.applicationForm)
                    tagButton.isSelected = true
                }

                applicationFormTagButtons.append(tagButton)
                applicationFormsTagsView.addSubview(tagButton)
            }
    }

    private func applicationFormTouchUpInside(applicationForm: ApplicationForm) {
        presenter.searchTriggered(with: self.searchedQuery, applicationForm: selectedApplicationForm)
    }

    func updateDrugList(drugs: [DrugReferenceViewData]) {
        if dataSource == nil {
            let dataSource = DrugListDataSource(items: drugs)
            tableView.dataSource = dataSource
            tableView.reloadData()
            self.dataSource = dataSource
        } else {
            self.dataSource?.update(items: drugs, in: tableView)
        }
    }

    func showIsLoading(_ isLoading: Bool) {
        stackView.isHidden = isLoading
        isLoading ? loadingOverlayView.show() : loadingOverlayView.hide()
    }
}

extension DrugListViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchedQuery = searchText
        presenter.searchTriggered(with: searchedQuery, applicationForm: selectedApplicationForm)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension DrugListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource?.item(at: indexPath) else { return }
        presenter.navigate(to: item.id, title: item.name)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Setup View

extension DrugListViewController {

    private func setupView() {
        view.backgroundColor = .backgroundPrimary

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])

        stackView.addArrangedSubview(pillIndicator)
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(Spacing.s, after: titleLabel)
        stackView.addArrangedSubview(tableView)

        headerView.addArrangedSubview(searchBar)
        headerView.setCustomSpacing(Spacing.s, after: searchBar)
        headerView.addArrangedSubview(tagsTitleLabel)
        headerView.addArrangedSubview(applicationFormsTagsView)

        tableView.tableHeaderView = headerView
        view.addSubview(loadingOverlayView)

        NSLayoutConstraint.activate([
            headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Sets a size value for the `headerView` that optimally satisfies the view's constraints.
        if let headerView = tableView.tableHeaderView {
            let fittingSize = CGSize(width: tableView.bounds.width, height: 110)
            let size = headerView.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            let headerViewFrame = CGRect(origin: .zero, size: size)
            if headerView.frame != headerViewFrame {
                headerView.frame = headerViewFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
}
