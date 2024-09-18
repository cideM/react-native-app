//
//  LibraryViewController.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/23/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization

/// @mockable
protocol LibraryViewType: AnyObject {
    func setTitle(_ title: String?)
    func setLearningCardTreeItems(_ learningCardTreeItems: [LearningCardTreeItem])
    func setIsSyncing(_ isSyncing: Bool)
}

final class LibraryViewController: UIViewController, LibraryViewType {

    let presenter: LibraryPresenterType
    private var dataSource = LibraryDataSource(learningCardTreeItems: [])

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.rowHeight = 62
        view.backgroundColor = ThemeManager.currentTheme.backgroundColor
        view.backgroundView = activityIndicatorView
        view.delegate = self
        view.tableFooterView = UIView()
        return view
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .medium
        view.hidesWhenStopped = true
        return view
    }()

    init(presenter: LibraryPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        title = L10n.Library.title
        tabBarItem.image = Asset.Icon.library.image
        navigationItem.largeTitleDisplayMode = .never
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = .backgroundPrimary

        view.addSubview(tableView)
        tableView.constrainEdges(to: view)
        dataSource.setupTableView(tableView)

        if navigationItem.largeTitleDisplayMode == .always {

            navigationItem.searchController = UISearchController(searchResultsController: nil)
            navigationItem.hidesSearchBarWhenScrolling = false

            navigationItem.searchController?.delegate = self
            navigationItem.searchController?.searchBar.delegate = self

            let attributedPlaceholder = NSAttributedString(string: L10n.Search.placeholder,
                                                           attributes: ThemeManager.currentTheme.searchTextFieldPlaceholderTextAttributes)

            navigationItem.searchController?.searchBar.styled(with: attributedPlaceholder,
                                                              image: Asset.Icon.search.image,
                                                              backgroundColor: .backgroundPrimary,
                                                              tintColor: .iconOnAccent,
                                                              barTintColor: ThemeManager.currentTheme.tintColor,
                                                              imageTintColor: ThemeManager.currentTheme.contentListSearchIconTintColor)

        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: Asset.Icon.search.image, style: .plain) { [weak presenter] _ in
                presenter?.didSelectSearch()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // The `.styled` method is called twice because when the device is rotated, the UISearchBar loses its style.
        // This will be fixed by this ticket: https://miamed.atlassian.net/browse/SPG-574
        if navigationItem.largeTitleDisplayMode == .always {
            let attributedPlaceholder = NSAttributedString(string: L10n.Search.placeholder,
                                                           attributes: ThemeManager.currentTheme.searchTextFieldPlaceholderTextAttributes)
            navigationItem.searchController?.searchBar.styled(with: attributedPlaceholder,
                                                              image: Asset.Icon.search.image,
                                                              backgroundColor: .backgroundPrimary,
                                                              tintColor: .iconOnAccent,
                                                              barTintColor: ThemeManager.currentTheme.tintColor,
                                                              imageTintColor: ThemeManager.currentTheme.contentListSearchIconTintColor)
        }
    }

    func setLearningCardTreeItems(_ learningCardTreeItems: [LearningCardTreeItem]) {
        dataSource = LibraryDataSource(learningCardTreeItems: learningCardTreeItems)
        tableView.dataSource = dataSource
        tableView.reloadData()
    }

    func setTitle(_ title: String?) {
        self.title = title
    }

    func setIsSyncing(_ isSyncing: Bool) {
        isSyncing ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    }
}

extension LibraryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let learningCardTreeItem = dataSource.learningCardAtIndex(indexPath.row) else { return }
        presenter.didSelectItem(learningCardTreeItem)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LibraryViewController: UISearchControllerDelegate {
    // unused:ignore UISearchControllerDelegate
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.isActive = false
    }
}

extension LibraryViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        presenter.didSelectSearch()
        return false
    }
}
