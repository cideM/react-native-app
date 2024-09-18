//
//  KeyValueTableViewDatasource.swift
//  DeveloperOverlay
//
//  Created by CSH on 12.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import UIKit

class KeyValueTableViewDatasource: NSObject, UITableViewDataSource {

    let sections: [KeyValueSection]

    init(_ sections: [KeyValueSection]) {
        self.sections = sections
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.section(at: section)?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleTableViewCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = item(at: indexPath).key
        cell.detailTextLabel?.text = item(at: indexPath).value.description.replacingOccurrences(of: "\n", with: "\\n")
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = self.section(at: section),
            !section.items.isEmpty else { return nil }
        return section.title
    }

    func section(at index: Int) -> KeyValueSection? {
        guard index < sections.count else { return nil }
        return sections[index]
    }

    func item(at indexPath: IndexPath) -> KeyValueItem {
        guard let section = self.section(at: indexPath.section),
            indexPath.row < section.items.count else {
            fatalError("Index out of bounds")
        }
        return section.items[indexPath.row]
    }
}
