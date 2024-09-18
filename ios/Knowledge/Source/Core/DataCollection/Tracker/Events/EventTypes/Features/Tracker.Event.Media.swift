//
//  Tracker.Event.Media.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 18.06.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

extension Tracker.Event {
    enum Media {
        case imageMediaviewerToggleImageExplanations(articleId: String? = nil, imageId: String, toggleState: ToggleState)
        case imageMediaviewerToggleOverlay(articleId: String? = nil, imageId: String, toggleState: ToggleState)
        case imageMediaviewerToggleSmartzoom(articleId: String? = nil, imageId: String, toggleState: ToggleState)
        case imageMediaviewerWasHidden(articleId: String? = nil, imageId: String? = nil, media: Media? = nil, externalAddition: ExternalAddition? = nil, referrer: Referrer)
        case imageMediaviewerWasShown(articleId: String? = nil, imageId: String? = nil, media: Media? = nil, externalAddition: ExternalAddition? = nil, referrer: Referrer)
        case videoMediaviewerWasShown(articleId: String? = nil, mediaUrl: String, referrer: Referrer)
    }
}

extension Tracker.Event.Media {
    enum ToggleState: String {
        case toggleOn = "on"
        case toggleOff = "off"
    }

    struct Media {
        let eid: String
        let title: String?
        let typeName: String = "MediaAsset"
    }

    struct Referrer {
        let articleEid: String
        let type: String = "article"
    }

    struct ExternalAddition {
        let type: String
        let typeName: String = "ExternalAddition"
    }
}
