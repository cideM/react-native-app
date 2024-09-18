//
//  SettingsTableViewDataSource.swift
//  Knowledge DE
//
//  Created by CSH on 25.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

final class SettingsTableViewDataSource: NSObject {

    private let sections: [Settings.Section]

    init(sections: [Settings.Section]) {
        self.sections = sections
    }

    func setup(_ tableView: UITableView) {
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.reuseIdentifier)
    }

    func section(at index: Int) -> Settings.Section? {
        assert(index < sections.count)
        return sections[index]
    }

    func item(at indexPath: IndexPath) -> Settings.Item? {
        guard let section = section(at: indexPath.section),
            indexPath.row < section.items.count else {
                assertionFailure("Index out of bounds")
                return nil
        }
        return section.items[indexPath.row]
    }

}

extension SettingsTableViewDataSource: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = self.section(at: section) else { return 0 }
        return section.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.reuseIdentifier) as? SettingsTableViewCell else { return UITableViewCell() }
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view =
                tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsSectionHeaderView.reuseIdentifier) as? SettingsSectionHeaderView
        else { return nil }
        view.titleLabel.attributedText = .attributedString(with: sections[section].title, style: .h6, decorations: [.color(.textTertiary)])
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            30
    }
}
