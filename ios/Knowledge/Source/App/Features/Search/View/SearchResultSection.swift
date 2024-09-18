//
//  SearchResultSection.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 01.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

struct SearchResultSection {
    let headerType: HeaderType?
    let items: [SearchResultItemViewData]
}

extension SearchResultSection {
    struct SearchResultHeaderData {
        let iconImage: ImageAsset
        let title: String
        let informationImage: ImageAsset?
        let buttonTitle: String
        let buttonAction: () -> Void
    }

    enum HeaderType {
        case `default`(title: String)
        case searchResult(data: SearchResultHeaderData)
        case mediaResult(filters: [SearchFilterViewItem])
    }
}
