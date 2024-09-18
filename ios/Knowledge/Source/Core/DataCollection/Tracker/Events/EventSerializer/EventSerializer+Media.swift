//
//  SegmentTrackingSerializer+Media.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 18.06.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

extension EventSerializer {
    func name(for event: Tracker.Event.Media) -> String? {
        switch event {
        case .imageMediaviewerToggleImageExplanations: return "image_mediaviewer_toggle_image_explanations"
        case .imageMediaviewerToggleOverlay: return "image_mediaviewer_toggle_overlay"
        case .imageMediaviewerToggleSmartzoom: return "image_mediaviewer_toggle_smartzoom"
        case .imageMediaviewerWasHidden: return "image_mediaviewer_was_hidden"
        case .imageMediaviewerWasShown: return "image_mediaviewer_was_shown"
        case .videoMediaviewerWasShown: return "video_mediaviewer_was_shown"
        }
    }

    func parameters(for event: Tracker.Event.Media) -> [String: Any]? {
        let parameters = SegmentParameter.Container<SegmentParameter.Media>()
        switch event {
        case .imageMediaviewerToggleImageExplanations(let articleId, let imageId, let toggleState):
            parameters.set(articleId, for: .articleXid)
            parameters.set(imageId, for: .imageXid)
            parameters.set(toggleState, for: .toggleState)

        case .imageMediaviewerToggleOverlay(let articleId, let imageId, let toggleState):
            parameters.set(articleId, for: .articleXid)
            parameters.set(imageId, for: .imageXid)
            parameters.set(toggleState, for: .toggleState)

        case .imageMediaviewerToggleSmartzoom(let articleId, let imageId, let toggleState):
            parameters.set(articleId, for: .articleXid)
            parameters.set(imageId, for: .imageXid)
            parameters.set(toggleState, for: .toggleState)

        case .imageMediaviewerWasHidden(let articleId, let imageId, let media, let externalAddition, let referrer):
            parameters.set(articleId, for: .articleXid)
            parameters.set(imageId, for: .imageXid)
            parameters.set(value(for: media), for: .media)
            parameters.set(value(for: referrer), for: .referrer)
            parameters.set(value(for: externalAddition), for: .externalAddition)

        case .imageMediaviewerWasShown(let articleId, let imageId, let media, let externalAddition, let referrer):
            parameters.set(articleId, for: .articleXid)
            parameters.set(imageId, for: .imageXid)
            parameters.set(value(for: media), for: .media)
            parameters.set(value(for: referrer), for: .referrer)
            parameters.set(value(for: externalAddition), for: .externalAddition)

        case .videoMediaviewerWasShown(let articleId, let mediaUrl, let referrer):
            parameters.set(articleId, for: .articleXid)
            parameters.set(mediaUrl, for: .mediaUrl)
            parameters.set(value(for: referrer), for: .referrer)
        }
        return parameters.data
    }

    func value(for parameter: Tracker.Event.Media.Media?) -> [String: Any]? {
        guard let parameter = parameter else { return nil }

        return [
            "eid": parameter.eid,
            "title": parameter.title as Any,
            "__typename": parameter.typeName
        ]
    }

    func value(for parameter: Tracker.Event.Media.Referrer?) -> [String: Any]? {
        guard let parameter = parameter else { return nil }

        return [
            "articleEID": parameter.articleEid,
            "type": parameter.type
        ]
    }

    func value(for parameter: Tracker.Event.Media.ExternalAddition?) -> [String: Any]? {
        guard let parameter = parameter else { return nil }

        return [
            "type": parameter.type,
            "__typename": parameter.typeName
        ]
    }

}

extension SegmentParameter {
    enum Media: String {
        case articleXid = "article_xid"
        case imageXid = "image_xid"
        case toggleState = "toggle_state"
        case mediaUrl = "media_url"
        case media
        case referrer
        case externalAddition
    }
}
