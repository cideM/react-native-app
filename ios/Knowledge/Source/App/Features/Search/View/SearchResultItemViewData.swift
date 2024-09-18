//
//  SearchResultItemViewData.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 02.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import DesignSystem

enum SearchResultItemViewData {
    case history(String)
    case autocomplete(suggestedTerm: AutocompleteViewItem, query: String)
    case instantResult(suggestedTerm: InstantResultViewItem, query: String)
    case phrasionary(phrasionary: PhrasionaryView.ViewData)
    case article(articleSearchViewItem: ArticleSearchViewItem, query: String)
    case pharma(pharmaSearchViewItem: PharmaSearchViewItem, query: String, database: DatabaseType)
    case monograph(item: MonographSearchViewItem, query: String)
    case guideline(guidelineSearchViewItem: GuidelineSearchViewItem, query: String)
    case media(mediaSearchViewItem: MediaSearchViewItem, query: String)
    case mediaOverview(mediaSearchOverviewItems: [MediaSearchOverviewItem], query: String)
}
