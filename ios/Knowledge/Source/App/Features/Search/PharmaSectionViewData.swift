//
//  PharmaSectionViewData.swift
//  Knowledge
//
//  Created by Silvio Bulla on 21.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation
import RichTextRenderer

protocol ExpandableSection {
    var isExpanded: Bool { get }
    var isHeaderVisible: Bool { get }
}

struct PharmaSectionViewData: ExpandableSection {

    let title: String
    let richText: RichTextDocument?
    var isExpanded: Bool
    var isHeaderVisible: Bool

    @LazyInject private static var monitor: Monitoring

    init(pharmaSection: PharmaSection, isExpanded: Bool = false) {
        title = pharmaSection.title
        isHeaderVisible = true
        self.isExpanded = isExpanded

        if let text = pharmaSection.text {
            richText = Self.richText(from: text)
        } else {
            richText = nil
        }
    }

    init(section: PocketCard.Section) {
        title = section.title
        isHeaderVisible = false
        isExpanded = true
        richText = Self.richText(from: section.content)
    }

    private static func richText(from text: String) -> RichTextDocument? {
        guard let data = text.data(using: .utf8) else { monitor.error("Failed to parse a Pharma section to Data", context: .pharma); return nil }

        do {
            return try JSONDecoder().decode(RichTextDocument.self, from: data)
        } catch {
            monitor.error("Failed to parse a Pharma section to a rich text document. Error: \(error)", context: .pharma)
            return nil
        }
    }
}

extension PharmaSectionViewData: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(richText)
        hasher.combine(isExpanded)
        hasher.combine(isHeaderVisible)
    }
}
