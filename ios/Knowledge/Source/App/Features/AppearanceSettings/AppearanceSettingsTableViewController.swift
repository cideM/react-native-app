//
//  AppearanceTableViewController.swift
//  Knowledge DE
//
//  Created by Silvio Bulla on 08.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

/// @mockable
protocol AppearanceSettingsTableViewType: AnyObject {
    func setSections(_ sections: [AppearanceSettingsSection])
}

final class AppearanceSettingsTableViewController: UITableViewController, AppearanceSettingsTableViewType, StoryboardIdentifiable {
    private let presenter: AppearanceSettingsPresenterType

    private var keepScreenActiveSwitch: UISwitch?
    private var sections: [AppearanceSettingsSection] = []
    private var interfaceStyles: [UIUserInterfaceStyle] = [.unspecified, .light, .dark]

    init(presenter: AppearanceSettingsPresenterType) {
        self.presenter = presenter
        super.init(style: .grouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.view = self
    }

    private func setupView() {
        title = L10n.AppearanceSettings.title
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .canvas
        tableView.separatorStyle = .singleLine
        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc func keepScreenActiveSwitchDidChange() {
        guard let keepScreenActiveSwitch else { return }
        presenter.keepScreenActiveDidChange(isEnabled: keepScreenActiveSwitch.isOn)
    }

    func setSections(_ sections: [AppearanceSettingsSection]) {
        self.sections = sections
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .keepScreenOn: return 1
        case .theme: return interfaceStyles.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .theme: return L10n.AppearanceSettings.title
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .keepScreenOn(let isEnabled):
            let cell = createSwitchCell()
            keepScreenActiveSwitch?.setOn(isEnabled, animated: false)
            return cell

        case .theme(let style):
            let cell: UITableViewCell = {
                let reuseID = "ThemeCell"
                guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseID) else {
                    return UITableViewCell(style: .default, reuseIdentifier: reuseID)
                }
                return cell
            }()
            let item = interfaceStyles[indexPath.row]
            cell.selectionStyle = .none
            cell.textLabel?.text = item.title
            cell.textLabel?.font = Font.medium.font(withSize: 17)
            cell.textLabel?.textColor = .textSecondary
            cell.accessoryType = item == style ? .checkmark : .none
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .theme:
            presenter.userInterfaceStyleDidChange(style: self.interfaceStyles[indexPath.row])
        default: break
        }
    }

    private func createSwitchCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = L10n.AppearanceSettings.KeepScreenOn.title
        cell.textLabel?.font = Font.medium.font(withSize: 17)
        cell.textLabel?.textColor = .textSecondary
        cell.detailTextLabel?.text = L10n.AppearanceSettings.KeepScreenOn.description
        cell.detailTextLabel?.textColor = .textTertiary
        cell.selectionStyle = .none

        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = .backgroundAccent
        switchView.addTarget(self, action: #selector(self.keepScreenActiveSwitchDidChange), for: .valueChanged)
        keepScreenActiveSwitch = switchView

        cell.accessoryView = switchView
        return cell
    }
}

extension UIUserInterfaceStyle {
    var title: String {
        switch self {
        case .dark: return L10n.AppearanceSettings.Option.Dark.title
        case .light: return L10n.AppearanceSettings.Option.Light.title
        case .unspecified: return L10n.AppearanceSettings.Option.System.title
        @unknown default: return ""
        }
    }
}
