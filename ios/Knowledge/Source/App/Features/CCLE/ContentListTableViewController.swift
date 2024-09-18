//
//  ContentListTableViewController.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 29.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

/// @mockable
protocol ContentListViewType: AnyObject {
    func setUp(title: String, placeholder: String)
    func setViewState(_ state: ContentListViewState)
    func setOverlay(_ isOn: Bool)
}

enum ContentListViewState {
    case loading
    case loaded(viewData: ContentListViewData, scrolledToTop: Bool)
    case error(title: String, subtitle: String, actionTitle: String)
    case empty(title: String, subtitle: String)
}

final class ContentListTableViewController: UIViewController {

    private let presenter: ContentListPresenterType
    private static let overlayAlpha: CGFloat = 0.7
    private static let animationsDuration: CGFloat = 0.3

    private var dataSource: ContentListDataSource? {
        didSet {
            dataSource?.setup(in: tableView)
            tableView.dataSource = dataSource
            tableView.reloadData()
        }
    }

    init(presenter: ContentListPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        view.backgroundColor = .backgroundPrimary
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = .zero
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = ThemeManager.currentTheme.backgroundColor
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1)) // Remove the last separator
        tableView.insetsContentViewsToSafeArea = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchTextField.delegate = self
        searchBar.backgroundColor = .canvas
        searchBar.showsCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .medium
        view.hidesWhenStopped = true
        return view
    }()

    private lazy var messagView: ContentListMessageView = {
        let view = ContentListMessageView()
        view.delegate = self
        view.alpha = .zero
        view.backgroundColor = ThemeManager.currentTheme.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var overlayView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = .backgroundPrimary
        view.alpha = .zero
        view.isHidden = true
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.currentTheme.backgroundColor

        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(messagView)
        view.addSubview(overlayView)
        view.addSubview(activityIndicatorView)

        messagView.constrain(to: tableView)
        overlayView.constrain(to: tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -1),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        presenter.view = self
    }
}

extension ContentListTableViewController: ContentListViewType {
    func setUp(title: String, placeholder: String) {
        self.title = title
        let attributedPlaceholder = NSAttributedString(string: placeholder,
                                                       attributes: ThemeManager.currentTheme.searchTextFieldPlaceholderTextAttributes)

        searchBar.styled(with: attributedPlaceholder,
                         image: Asset.Icon.searchList.image,
                         backgroundColor: .backgroundPrimary,
                         tintColor: .iconOnAccent,
                         barTintColor: ThemeManager.currentTheme.tintColor,
                         imageTintColor: ThemeManager.currentTheme.contentListSearchIconTintColor)
    }

    func setViewState(_ state: ContentListViewState) {
        switch state {
        case .loading:
            navigationItem.backBarButtonItem?.title = ""
            hideMessage()
            setOverlay(visible: true, animated: true)
            activityIndicatorView.startAnimating()
        case .loaded(let viewData, let scrolledToTop):
            dataSource = ContentListDataSource(viewData: viewData)
            setOverlay(visible: false, animated: false)
            activityIndicatorView.stopAnimating()
            if scrolledToTop, !viewData.items.isEmpty {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                      at: .top,
                                      animated: false)
            }
        case .error(let title, let subtitle, let actionTitle):
            showMessage(title: title, subtitle: subtitle, actionTitle: actionTitle)
            setOverlay(visible: false, animated: false)
            activityIndicatorView.stopAnimating()
        case .empty(let title, let subtitle):
            showMessage(title: title, subtitle: subtitle)
            setOverlay(visible: false, animated: false)
            activityIndicatorView.stopAnimating()
        }
    }

    func setOverlay(_ isOn: Bool) {
        setOverlay(visible: isOn, animated: true)
    }

    private func showMessage(title: String, subtitle: String, actionTitle: String? = nil) {
        messagView.configure(title: title, subtitle: subtitle, actionTitle: actionTitle)

        UIView.animate(withDuration: Self.animationsDuration) { [weak self] in
            self?.messagView.alpha = 1
        }
    }

    private func hideMessage() {
        UIView.animate(withDuration: Self.animationsDuration) { [weak self] in
            self?.messagView.alpha = 0
        }
    }

    private func setOverlay(visible: Bool, animated: Bool) {
        if animated {
            if visible {
                self.overlayView.alpha = 0
                self.overlayView.isHidden = false
            }
            UIView.animate(withDuration: Self.animationsDuration, animations: { [weak self] in
                self?.overlayView.alpha = visible ? Self.overlayAlpha : .zero
            }, completion: { [weak self] _ in
                self?.overlayView.isHidden = !visible
            })
        } else {
            overlayView.alpha = visible ? Self.overlayAlpha : .zero
            overlayView.isHidden = !visible
        }
    }
}

extension ContentListTableViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchButtonTapped(query: searchBar.text ?? "")
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(true, animated: false)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchBarCancelButtonTapped()
        searchBar.searchTextField.text = ""
        searchBar.resignFirstResponder()
    }
}

extension ContentListTableViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        presenter.searchBarTapped()
        return presenter.searchBarTextFieldCanBeginEditting()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        presenter.searchBarTextFieldDidBeginEditing()
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        presenter.searchBarTextFieldDidEndEditing()
        if textField.text?.isEmpty ?? true {
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
}

extension ContentListTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let dataSource = dataSource else { return }
        let numberOfItems = dataSource.tableView(tableView, numberOfRowsInSection: 0)
        if indexPath.row == numberOfItems - presenter.paginationThreshold {
            presenter.didScrollToBottom()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource?.item(at: indexPath) else { return }
        presenter.didSelect(item: item)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension ContentListTableViewController: ContentListMessageViewDelegate {
    func didTapActionButton() {
        presenter.retryButtonTapped()
    }
}
