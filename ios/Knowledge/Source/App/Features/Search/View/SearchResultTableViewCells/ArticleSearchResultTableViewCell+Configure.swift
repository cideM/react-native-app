//
//  ArticleSearchResultTableViewCell+Configure.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 01.08.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import DesignSystem
import Foundation

extension SearchResultView {

    func configure(articleItem: ArticleSearchViewItem,
                   indexPath: IndexPath,
                   delegate: SearchResultViewDelegate?) {
        configure(viewData: ViewData(title: articleItem.title,
                                     body: articleItem.body,
                                     indexPath: indexPath,
                                     children: articleItem.children.map { SearchResultChildView.ViewData(
                                        title: $0.title,
                                        body: $0.body,
                                        level: $0.level)
                                     }),
                  delegate: delegate)
    }

    func configure(monographItem: MonographSearchViewItem,
                   indexPath: IndexPath,
                   delegate: SearchResultViewDelegate?) {
        configure(viewData: ViewData(title: monographItem.title,
                                     body: monographItem.body,
                                     indexPath: indexPath,
                                     children: monographItem.children.map { SearchResultChildView.ViewData(
                                        title: $0.title,
                                        body: $0.body,
                                        level: $0.level)
                                     }),
                  delegate: delegate)
    }
}
