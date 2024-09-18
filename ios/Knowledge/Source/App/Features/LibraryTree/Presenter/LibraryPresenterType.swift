//
//  LibraryPresenterType.swift
//  Knowledge DE
//
//  Created by Mohamed Abdul Hameed on 09.12.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain

protocol LibraryPresenterType: AnyObject {
    var view: LibraryViewType? { get set }

    func didSelectItem(_ item: LearningCardTreeItem)
    func didSelectSearch()
}
