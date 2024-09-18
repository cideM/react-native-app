//
//  ContentCardsDataSource.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 26.10.23.
//

import DesignSystem
import UIKit

class ContentCardsDataSource: NSObject, GenericListTableViewDataSourceType {
    typealias ViewData = ContentCardView.ViewData
    
    var data: [ViewData] = []
    
    func registerCells(in tableView: UITableView) {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(GenericTableViewCell<ContentCardView>.self, forCellReuseIdentifier: GenericTableViewCell<ContentCardView>.reuseIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GenericTableViewCell<ContentCardView> = tableView.dequeuedCell()
        cell.view.setup(with: data[indexPath.row], delegate: nil)
        return cell
    }
}
