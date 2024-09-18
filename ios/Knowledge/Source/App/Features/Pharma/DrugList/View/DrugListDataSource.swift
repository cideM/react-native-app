//
//  DrugListDataSource.swift
//  Knowledge DE
//
//  Created by Merve Kavaklioglu on 13.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit

class DrugListDataSource: NSObject {

    private var items = [DrugReferenceViewData]()
    private var tableView: UITableView?

    init(items: [DrugReferenceViewData]) {
        self.items = items
    }

    func item(at indexPath: IndexPath) -> DrugReferenceViewData? {
        items[indexPath.row]
    }

    func update(items: [DrugReferenceViewData], in tableView: UITableView) {
        let oldItems = self.items
        self.items = items

        tableView.performBatchUpdates {

            // Removes dropped items  ...
            for (oldIndex, oldItem) in oldItems.enumerated() {
                if !items.contains(oldItem) {
                    tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .fade)
                }
            }

            // Add new items ...
            for (newIndex, item) in items.enumerated() {
                if let oldIndex = oldItems.firstIndex(of: item) {

                    // Move existing item in case it changed place ...
                    if newIndex != oldIndex {
                        tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .fade)
                        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .fade)
                    } else {
                        // Do nothing, item is already in the right spot ...
                    }

                } else {
                    // Add item, that did not exist before ...
                    tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .fade)
                }
            }
        }
    }
}

extension DrugListDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = self.item(at: indexPath) else {
            assertionFailure("No Item found")
            return UITableViewCell()
        }

        let cell: DrugListTableViewCell = tableView.dequeuedCell()
        cell.configure(item: item)
        return cell
    }
}
