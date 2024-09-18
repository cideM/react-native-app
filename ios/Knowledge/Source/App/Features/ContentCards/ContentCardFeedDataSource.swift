//
//  ContentCardFeedDataSource.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 18.10.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import UIKit
import DesignSystem

protocol ContentCardFeedDataSourceDelegate: AnyObject {
    func didTapContentCard(at index: Int)
}

class ContentCardFeedDataSource: NSObject, GenericListTableViewDataSourceType {
    typealias ViewData = ContentCardView.ViewData

    weak var delegate: ContentCardFeedDataSourceDelegate?

    var data: [ViewData] = []

    func registerCells(in tableView: UITableView) {
        tableView.register(GenericTableViewCell<ContentCardView>.self, forCellReuseIdentifier: GenericTableViewCell<ContentCardView>.reuseIdentifier)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GenericTableViewCell<ContentCardView> = tableView.dequeuedCell()
        cell.view.setup(with: data[indexPath.row], delegate: self)
        return cell
    }
}

extension ContentCardFeedDataSource: ContentCardViewDelegate {
    func didTapContentCard(at index: Int) {
        self.delegate?.didTapContentCard(at: index)
    }

    func didDismissContentCard(at index: Int) { }

    func didViewContentCard(at index: Int) { }

    func shouldOpenContentCardFeed() { }
}

extension GenericListTableViewController: ContentCardFeedDataSourceDelegate where DataSource == ContentCardFeedDataSource, Presenter == ContentCardFeedPresenter {
    func didTapContentCard(at index: Int) {
        self.presenter?.didTapContentCard(at: index)
    }
}
