//
//  CalloutViewDataSource.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 21.11.23.
//

import DesignSystem
import UIKit

class CalloutViewDataSource: NSObject, GenericListTableViewDataSourceType {

    typealias ViewData = CalloutView.ViewData

    var data: [ViewData] = []

    func registerCells(in tableView: UITableView) {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(GenericTableViewCell<CalloutView>.self, forCellReuseIdentifier: GenericTableViewCell<CalloutView>.reuseIdentifier)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GenericTableViewCell<CalloutView> = tableView.dequeuedCell()
        cell.view.viewData = data[indexPath.row]
        cell.updateInsets(UIEdgeInsets(all: .spacing.xs))
        return cell
    }
}
