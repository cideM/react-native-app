//
//  SettingsTableViewController.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 20.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit
import Localization

/// @mockable
protocol SettingsViewType: AnyObject {
    func set(sections: [Settings.Section])
    func presentMessage(_ title: String, actions: [MessageAction])
}

final class SettingsTableViewController: UIViewController, SettingsViewType {
    private let presenter: SettingsPresenterType
    private var dataSource = SettingsTableViewDataSource(sections: [])
    private let analyticsTracker: TrackingType

    init(presenter: SettingsPresenterType, analyticsTracker: TrackingType = resolve()) {
        self.presenter = presenter
        self.analyticsTracker = analyticsTracker
        super.init(nibName: nil, bundle: nil)
        title = L10n.Settings.title
        tabBarItem.image = Asset.Icon.settings.image
        navigationItem.largeTitleDisplayMode = .never
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.rowHeight = UITableView.automaticDimension
        view.sectionHeaderHeight = 30.0
        view.backgroundColor = ThemeManager.currentTheme.backgroundColor
        view.register(SettingsSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SettingsSectionHeaderView.reuseIdentifier)
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        view.backgroundColor = ThemeManager.currentTheme.backgroundColor
        view.addSubview(tableView)
        tableView.constrainEdges(to: view)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }

    func set(sections: [Settings.Section]) {
        // Improvement for the future: diff the data and possibly only update certain rows
        let dataSource = SettingsTableViewDataSource(sections: sections)
        self.dataSource = dataSource
        dataSource.setup(tableView)
        tableView.dataSource = dataSource
        tableView.reloadData()
    }

    func presentMessage(_ title: String, actions: [MessageAction]) {
        UIAlertMessagePresenter(presentingViewController: self).present(title: title, actions: actions)
    }
}

extension SettingsTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.item(at: indexPath) else { return }
        presenter.didSelect(item: item)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == dataSource.numberOfSections(in: tableView) - 1 else { return nil }
        return SettingsFooterView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == dataSource.numberOfSections(in: tableView) - 1 ? 50.0 : 0.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        dataSource.tableView(tableView, viewForHeaderInSection: section)
        }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        dataSource.tableView(tableView, heightForHeaderInSection: section)
    }
}
