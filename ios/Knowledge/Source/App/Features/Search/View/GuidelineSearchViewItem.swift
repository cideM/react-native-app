//
//  GuidelineSearchViewItem.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 20.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

struct GuidelineSearchViewItem {
    let tag: String?
    let title: String
    let details: String?
    let externalURL: URL?
    let indexInfo: IndexInfo
    let targetUuid: String

    struct IndexInfo {
        let index: Int
        let subIndex: Int?
        // sourcery: fixture:
        init(index: Int, subIndex: Int?) {
            self.index = index
            self.subIndex = subIndex
        }
    }

    // sourcery: fixture:
    init(tag: String?, title: String, details: String?, externalURL: URL?, indexInfo: IndexInfo, targetUUid: String) {
        self.tag = tag
        self.title = title
        self.details = details
        self.externalURL = externalURL
        self.indexInfo = indexInfo
        self.targetUuid = targetUUid
    }

    init(item: GuidelineSearchItem, indexInfo: IndexInfo) {
         let detailsString = (item.details ?? []).reduce(into: String()) { result, string in result.append("<br>\(string)") } // Adding a <br> here to make sure the HTML parser breaks the line between multple items ...
        self.init(tag: item.tags?.first, title: item.title, details: detailsString, externalURL: URL(string: item.externalURL ?? ""), indexInfo: indexInfo, targetUUid: item.targetUUID)
     }
}
