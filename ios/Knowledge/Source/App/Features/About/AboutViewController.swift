//
//  AboutViewController.swift
//  Knowledge
//
//  Created by Silvio Bulla on 23.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

/// @mockable
protocol AboutViewType: AnyObject {
    func setData(_ items: [AboutViewItem])
}

final class AboutViewController: UIViewController, AboutViewType {

    private let presenter: AboutPresenterType
    private var items: [AboutViewItem] = []

    init(presenter: AboutPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        title = L10n.Settings.More.About.title

    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = ThemeManager.currentTheme.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self

        view.backgroundColor = ThemeManager.currentTheme.backgroundColor
        view.addSubview(tableView)
        tableView.constrainEdges(to: view)
    }

    func setData(_ items: [AboutViewItem]) {
        self.items = items
        tableView.reloadData()
    }
}

extension AboutViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.backgroundColor = .backgroundPrimary
        cell.textLabel?.attributedText = NSAttributedString(string: items[indexPath.row].title, attributes: ThemeManager.currentTheme.selectableCellTitleTextAttributes)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelect(item: items[indexPath.row])
    }
}
