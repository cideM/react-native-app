//
//  RoutedTableViewSectionType.swift
//  DesignSytemPreview
//
//  Created by Elmar Tampe on 01.08.23.
//

import UIKit

protocol RoutedTableViewSectionType: UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView? { get set }
    func registerCellTypes()
}
