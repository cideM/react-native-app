//
//  MonographSearchViewItem.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 07.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Common
import DesignSystem

struct MonographSearchViewItem {
    let title: NSAttributedString?
    let body: NSAttributedString?
    let deeplink: MonographDeeplink
    let resultIndex: Int
    let children: [ChildSearchResultViewItem]
    let targetUuid: String
    var monographId: MonographIdentifier {
        deeplink.monograph
    }
    // sourcery: fixture:
    init(title: String,
         details: [String]?,
         deeplink: MonographDeeplink,
         resultIndex: Int,
         children: [ChildSearchResultViewItem],
         targetUuid: String) {

        let bodyString = details?.reduce(into: String()) { result, string in result.append("<br>\(string)") }
        self.title = try? HTMLParser.attributedStringFromHTML(htmlString: title, with: Self.titleAttributes())
        if let body = bodyString {
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
