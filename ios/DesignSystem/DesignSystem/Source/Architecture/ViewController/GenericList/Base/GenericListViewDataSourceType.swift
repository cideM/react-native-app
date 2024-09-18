//
//  GenericListViewDataSourceType.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 20.10.23.
//

import UIKit

public protocol GenericListViewDataSourceType {
    associatedtype ViewData: GenericListViewData

    var data: [ViewData] { get set }
}

public protocol GenericListTableViewDataSourceType: GenericListViewDataSourceType, UITableViewDataSource, UITableViewDelegate {
    func registerCells(in tableView: UITableView)
}

public protocol GenericListCollectionViewDataSourceType: GenericListViewDataSourceType, UICollectionViewDataSource, UICollectionViewDelegate {
    func registerCells(in collectionView: UICollectionView)
}
