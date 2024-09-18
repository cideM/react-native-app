//
//  FavouritesViewController.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 26.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit

/// @mockable
protocol ListViewType: AnyObject {
    func setEmptyViewText(_ text: String)
    func setTagListViewItems(_ items: [TagListViewData])
}

final class ListViewController: UIViewController, ListViewType {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()

        tableView.rowHeight = 62

        tableView.backgroundColor = .backgroundPrimary
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        tableView.delegate = self

        return tableView
    }()
    private var dataSource = TagListViewDataSource(tagListViewItems: []) {
        didSet {
            tableView.dataSource = dataSource
        }
    }

    private let presenter: ListPresenterType

    init(presenter: ListPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource
        dataSource.setupTableView(tableView)

        setupTableView()

        presenter.view = self
    }

    func setEmptyViewText(_ text: String) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .backgroundPrimary

        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(label)
        label.attributedText = NSAttributedString(string: text, attributes: ThemeManager.currentTheme.recentsListEmptyStateTextAttributes)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16)
        ])
        tableView.backgroundView = backgroundView

        DispatchQueue.main.async {
            self.preferredContentSize = CGSize(width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height + 32) // 32 is needed because we want the label to have 16 points padding from top and bottom
        }
    }

    func setTagListViewItems(_ items: [TagListViewData]) {
        tableView.backgroundView = nil
        dataSource = TagListViewDataSource(tagListViewItems: items)
        tableView.reloadData()
        tableView.layoutIfNeeded() // This is only needed for iOS 12.
        self.preferredContentSize = tableView.contentSize
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.learningCardAtIndex(indexPath.item) else { return }
        presenter.didSelectItem(item)
    }
}
