//
//  ChildSearchResultViewItem.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 04.04.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Domain
import Common
import DesignSystem

struct ChildSearchResultViewItem {
    let deeplink: Deeplink
    let title: NSAttributedString?
    let body: NSAttributedString?
    let level: Int
    let sectionIndex: Int
    let targetUuid: String

    // sourcery: fixture:
    init(title: String,
         body: String?,
         deeplink: Deeplink,
         level: Int,
         sectionIndex: Int,
         targetUuid: String) {
        self.title = try? HTMLParser.attributedStringFromHTML(htmlString: title, with: Self.titleAttributes(level: level))
        if let body = body {
            self.body = try? HTMLParser.attributedStringFromHTML(htmlString: body, with: Self.bodyAttributes())
        } else {
            self.body = nil
        }
        self.deeplink = deeplink
        self.level = level
        self.sectionIndex = sectionIndex
        self.targetUuid = targetUuid
    }

    private static func titleAttributes(level: Int) -> HTMLParser.Attributes {
        switch level {
        case 1: // Section title
            return HTMLParser.Attributes(
                normal:
                        .attributes(style: .paragraph)
                        .with(.byTruncatingTail),
                bold:
                        .attributes(style: .paragraphBold)
                        .with(.byTruncatingTail),

                italic:
                        .attributes(style: .paragraph, with: [.italic])
                        .with(.byTruncatingTail)
            )

        default: // all other subsection titles
            return HTMLParser.Attributes(
                normal:
                        .attributes(style: .paragraphSmall)
                        .with(.byTruncatingTail),
                bold:
                        .attributes(style: .paragraphSmallBold)
                        .with(.byTruncatingTail),
                italic:
                        .attributes(style: .paragraphSmall, with: [.italic])
                        .with(.byTruncatingTail)
            )
        }
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
