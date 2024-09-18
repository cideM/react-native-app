//
//  SearchViewItem.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 09.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Common
import DesignSystem

struct ArticleSearchViewItem {

    let deeplink: LearningCardDeeplink
    let title: NSAttributedString?
    let body: NSAttributedString?
    let resultIndex: Int
    let children: [ChildSearchResultViewItem]
    let targetUuid: String

    // sourcery: fixture:
    init(title: String,
         body: String?,
         deeplink: LearningCardDeeplink,
         resultIndex: Int,
         children: [ChildSearchResultViewItem],
         targetUuid: String) {

        self.title = try? HTMLParser.attributedStringFromHTML(htmlString: title, with: Self.titleAttributes())
        if let body = body {
            self.body = try? HTMLParser.attributedStringFromHTML(htmlString: body, with: Self.bodyAttributes())
        } else {
            self.body = nil
        }
        self.deeplink = deeplink
        self.resultIndex = resultIndex
        self.children = children
        self.targetUuid = targetUuid
    }

    private static func titleAttributes() -> HTMLParser.Attributes {
        HTMLParser.Attributes(
            normal:
                    .attributes(style: .h5Bold, with: [.color(.textAccent)])
                    .with(.byTruncatingTail), // bold
            bold:
                    .attributes(style: .h5, with: [.color(.textAccent)])
                    .with(.byTruncatingTail), // black
            italic:
                    .attributes(style: .h5, with: [.color(.textAccent), .italic])
                    .with(.byTruncatingTail)
        )
    }

    private static func bodyAttributes() -> HTMLParser.Attributes {
        HTMLParser.Attributes(
            normal:
                    .attributes(style: .paragraphSmall, with: [.color(.textSecondary)])
                    .with(.byTruncatingTail),
            bold:
                    .attributes(style: .paragraphSmallBold, with: [.color(.textSecondary)])
                    .with(.byTruncatingTail),
            italic:
                    .attributes(style: .paragraphSmall, with: [.color(.textSecondary), .italic])
                    .with(.byTruncatingTail)
        )
    }
}
