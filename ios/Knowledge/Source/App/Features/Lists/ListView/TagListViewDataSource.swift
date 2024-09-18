//
//  TagListViewDataSource.swift
//  Knowledge
//
//  Created by Silvio Bulla on 10.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

final class TagListViewDataSource: NSObject {
    var isEmpty: Bool {
        tagListViewItems.isEmpty
    }
    private let tagListViewItems: [TagListViewData]
    private let tagRepository: TagRepositoryType

    init(tagListViewItems: [TagListViewData], tagRepository: TagRepositoryType = resolve()) {
        self.tagListViewItems = tagListViewItems
        self.tagRepository = tagRepository
    }

    func setupTableView(_ tableView: UITableView) {

        tableView.register(LibraryTreeLearningCardTableViewCell.self, forCellReuseIdentifier: LibraryTreeLearningCardTableViewCell.reuseIdentifier)
    }

    func learningCardAtIndex(_ index: Int) -> LearningCardMetaItem? {
        guard index >= 0, index <= tagListViewItems.count else { return nil }
        return  tagListViewItems[index].learningCardMetaItem
    }
}

extension TagListViewDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tagListViewItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()

        guard let learningCardMetaItem = learningCardAtIndex(indexPath.row) else {
            assert(false, "requested a cell out of bounds")
            return cell
        }

        if let learningCardCell = tableView.dequeueReusableCell(withIdentifier: LibraryTreeLearningCardTableViewCell.reuseIdentifier, for: indexPath) as? LibraryTreeLearningCardTableViewCell {
            cell = learningCardCell
            learningCardCell.configure(with: learningCardMetaItem.title, isFavorite: tagRepository.hasTag(.favorite, for: learningCardMetaItem.learningCardIdentifier), isLearned: tagRepository.hasTag(.learned, for: learningCardMetaItem.learningCardIdentifier))
        }

        return cell
    }
}
