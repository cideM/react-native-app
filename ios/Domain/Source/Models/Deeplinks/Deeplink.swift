//
//  Deeplink.swift
//  Interfaces
//
//  Created by Cornelius Horstmann on 07.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

// sourcery: fixture:
public enum Deeplink: Equatable {
    // The login case only exists in order to make sure the link opens the app and does nothing else
    // It can not be of type unsupported because that will bring up a dialog that asks
    // if the link shall be opened in a browser
    // Examples:
    // DE: https://www.amboss.com/de/app/wissen/login
    // US: https://www.amboss.com/us/app/wissen/login
    case login(LoginDeeplink)

    // Examples:
    // DE: 
    // https://www.amboss.com/de/library#xid=bH0HKh&anker=Zf974d8cff01b469f038157cfd85da31c
    // https://next.amboss.com/de/article/PS0W-2?q=leberzirrhose+-+pathologie#Z1a72b240f0dd96d2e9ebf3ead66d32f1
    // US:
    // https://www.amboss.com/us/library#xid=bH0HKh&anker=Zf974d8cff01b469f038157cfd85da31c
    // https://next.amboss.com/us/article/C30qkf#Zcdc4c4734f79cd371a2e2183527dfebd
    case learningCard(LearningCardDeeplink)

    // Examples:
    // DE: https://next.amboss.com/de/pharma/2168/1018580
    // US: Pharma links only exists in DE
    case pharmaCard(PharmaCardDeeplink)

    // Examples:
    // DE: https://next.amboss.com/de/search?q=Hals&v=overview
    // US: https://next.amboss.com/us/search?q=ramipril&v=guideline
    case search(SearchDeeplink?, source: Source = .standard)

    // Examples:
    // This is only being used internally via ContentListPresenter
    case uncommitedSearch(UncommitedSearchDeeplink)

    // Examples:
    // DE: Monograph links only exist in US
    // US: https://next.amboss.com/us/pharma/voxelotor?q=voxelotor
    case monograph(MonographDeeplink)

    // Examples:
    // DE: https://next.amboss.com/de/settings/appearance
    // US: https://next.amboss.com/us/settings/appearance
    case settings(SettingsDeeplink)

    // Examples:
    // DE: https://next.amboss.com/us/pocket-guides
    // US: https://next.amboss.com/de/pocket-guides
    case pocketGuides(PocketGuidesDeeplink)

    // Examples:
    // DE: https://www.amboss.com/de/account/accessChooser?key=[AMBOSS-ACCESS-CODE]
    // US: https://www.amboss.com/us/campuslicense/add?key=ST8CVVM2YCNQ
    // NOTE:
    // This is currently not supported in DE
    // See here for more context: https://miamed.atlassian.net/browse/PHEX-1733
    case productKey(ProductKeyDeeplink)

    // Unsupported
    // - Library Tree Deeplinks
    //      - https://next.amboss.com/de/library/Qh0udf/c30ahf
    //      - https://next.amboss.com/de/library/ai0QJf
    //      - https://next.amboss.com/de/library
    //      - https://next.amboss.com/us/library/Qh0udf/Fi0gtf
    // BUT THIS SHOULD STILL WORK: 
    //      - https://amboss.miamed.de/library#xid=kO0msT&anker=Z90b619609cb187c9b358e45ee6ab3a94
    // - Public Articles; These should be indirectly supported by smart banners which would convert them into "normal" article links
    //      - https://amboss.miamed.de/wissen/Sammelsurium_vorklinischer_Quiz-Bilder
    case unsupported(URL)

    public init(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            self = .unsupported(url)
            return
        }
        if let deeplink = LearningCardDeeplink(urlComponents: urlComponents) {
            self = .learningCard(deeplink)
        } else if let link = PharmaCardDeeplink(urlComponents: urlComponents) {
            self = .pharmaCard(link)
        } else if let link = MonographDeeplink(urlComponents: urlComponents) {
            self = .monograph(link)
        } else if let link = LoginDeeplink(urlComponents: urlComponents) {
            self = .login(link)
        } else if let link = SearchDeeplink(urlComponents: urlComponents) {
            self = .search(link)
        } else if let link = SettingsDeeplink(urlComponents: urlComponents) {
            self = .settings(link)
        } else if let link = PocketGuidesDeeplink(urlComponents: urlComponents) {
            self = .pocketGuides(link)
        } else if let link = ProductKeyDeeplink(urlComponents: urlComponents) {
            self = .productKey(link)
        } else {
            self = .unsupported(url)
        }
    }
}

public extension Deeplink {
    // sourcery: fixture:
    enum Source: Equatable {
        case standard
        case siri
    }
}
