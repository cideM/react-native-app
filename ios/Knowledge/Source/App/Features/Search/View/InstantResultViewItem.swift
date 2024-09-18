//
//  InstantResultViewItem.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 06.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

public struct InstantResultViewItem {

    public let attributedText: NSAttributedString
    public let value: String
    public let type: Kind

    public init(attributedText: NSAttributedString?, value: String?, type: Kind) {
        self.attributedText = attributedText ?? NSAttributedString(string: "")
        self.value = value ?? ""
        self.type = type
    }
}

public extension InstantResultViewItem {
    enum Kind {
        case article(LearningCardDeeplink, trackingData: SearchSuggestionItem)
        case pharmaCard(PharmaCardDeeplink, trackingData: SearchSuggestionItem)
        case monograph(MonographDeeplink, trackingData: SearchSuggestionItem)
    }
}
