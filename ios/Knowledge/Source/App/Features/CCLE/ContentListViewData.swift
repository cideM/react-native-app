//
//  ContentListViewData.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 29.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Domain

enum ContentListItemViewData {
    case pharma(item: PharmaSearchViewItem)
    case monograph(item: MonographSearchViewItem)
    case guideline(item: GuidelineSearchViewItem)
    case media(item: MediaSearchViewItem)
}

final class ContentListViewData {

    private(set) var items: [ContentListItemViewData] = []

    var isEmpty: Bool {
        items.isEmpty
    }
    func setItems(newItems: [ContentListItemViewData]) {
        self.items = newItems
    }

    func append(newItems: [ContentListItemViewData]) {
        self.items.append(contentsOf: newItems)
    }

}
