//
//  SearchSuggestionViewItem.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 04.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

public struct AutocompleteViewItem {

    public let text: NSAttributedString
    public let value: String
    public let trackingData: SearchSuggestionItem

    // sourcery: fixture:
    public init(text: NSAttributedString?, value: String?, trackingData: SearchSuggestionItem) {

        self.text = text ?? NSAttributedString()
        self.value = value ?? ""
        self.trackingData = trackingData
    }
}
