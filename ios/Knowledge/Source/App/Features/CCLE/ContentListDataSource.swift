//
//  ContentListDataSource.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 29.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit

final class ContentListDataSource: NSObject {

    var viewData: ContentListViewData

    init(viewData: ContentListViewData) {
        self.viewData = viewData
    }

    func item(at indexPath: IndexPath) -> ContentListItemViewData {
        viewData.items[indexPath.row]
    }

    func setup(in tableView: UITableView) {
        tableView.register(UINib(nibName: SearchResultTableViewCell.reuseIdentifier,
                                 bundle: nil),
                           forCellReuseIdentifier: SearchResultTableViewCell.reuseIdentifier)
    }

    func setup(in collectionView: UICollectionView) {
        collectionView.register(MediaSearchResultCollectionViewCell.self,
                                forCellWithReuseIdentifier: MediaSearchResultCollectionViewCell.reuseIdentifier)
    }

}

extension ContentListDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewData.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: SearchResultTableViewCell = tableView.dequeuedCell()

        switch viewData.items[indexPath.row] {

        case .pharma(let item):
            cell.configure(item: item)
        case .monograph(let item):
            cell.configure(item: item)
        case .guideline(let item):
            cell.configure(item: item)
        case .media:
            fatalError("Media items shouldn't be displayed in a table view")
        }
        return cell
    }

}

extension ContentListDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewData.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch viewData.items[indexPath.row] {
        case .media(let item):
            let cell: MediaSearchResultCollectionViewCell = collectionView.dequeuedCell(at: indexPath)
            cell.configure(item: item)
            return cell
        default:
            fatalError("Item shouldn't be displayed in a collection view")
        }
    }
}
