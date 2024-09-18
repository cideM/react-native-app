//
//  LibraryDataSource.swift
//  Knowledge
//
//  Created by Silvio Bulla on 29.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

final class LibraryDataSource: NSObject {

    private let learningCardTreeItems: [LearningCardTreeItem]
    private let tagRepository: TagRepositoryType

    init(learningCardTreeItems: [LearningCardTreeItem], tagRepository: TagRepositoryType = resolve()) {
        self.learningCardTreeItems = learningCardTreeItems
        self.tagRepository = tagRepository
    }

    func setupTableView(_ tableView: UITableView) {
        tableView.register(UINib(nibName: LibraryTreeFolderTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: LibraryTreeFolderTableViewCell.reuseIdentifier)
        tableView.register(LibraryTreeLearningCardTableViewCell.self, forCellReuseIdentifier: LibraryTreeLearningCardTableViewCell.reuseIdentifier)
    }

    func learningCardAtIndex(_ index: Int) -> LearningCardTreeItem? {
        guard index >= 0, index <= learningCardTreeItems.count else { return nil }
        return learningCardTreeItems[index]
    }
}

extension LibraryDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        learningCardTreeItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()

        guard let learningCardTreeItem = learningCardAtIndex(indexPath.row) else {
            assert(false, "requested a cell out of bounds")
            return cell
        }

        guard let learningCardIdentifier = learningCardTreeItem.learningCardIdentifier else {
            if let libraryTreeCell = tableView.dequeueReusableCell(withIdentifier: LibraryTreeFolderTableViewCell.reuseIdentifier, for: indexPath) as? LibraryTreeFolderTableViewCell {
                cell = libraryTreeCell
                libraryTreeCell.configure(title: learningCardTreeItem.title, childCount: learningCardTreeItem.childrenCount)
            }
            return cell
        }
        if let learningCardCell = tableView.dequeueReusableCell(withIdentifier: LibraryTreeLearningCardTableViewCell.reuseIdentifier, for: indexPath) as? LibraryTreeLearningCardTableViewCell {
            cell = learningCardCell
            learningCardCell.configure(with: learningCardTreeItem.title, isFavorite: tagRepository.hasTag(.favorite, for: learningCardIdentifier), isLearned: tagRepository.hasTag(.learned, for: learningCardIdentifier))
        }
        return cell
    }
}
