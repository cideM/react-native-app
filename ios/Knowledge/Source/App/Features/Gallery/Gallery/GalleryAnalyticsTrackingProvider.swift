//
//  GalleryAnalyticsTrackingProvider.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 21.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

final class GalleryAnalyticsTrackingProvider: GalleryAnalyticsTrackingProviderType {

    private let trackingProvider: TrackingType
    init(trackingProvider: TrackingType = resolve()) {
        self.trackingProvider = trackingProvider
    }

    func trackShowImageExplanations(imageID: ImageResourceIdentifier) {
        trackingProvider.track(.imageMediaviewerToggleImageExplanations(imageId: imageID.value, toggleState: .toggleOn))
    }

    func trackHideImageExplanations(imageID: ImageResourceIdentifier) {
        trackingProvider.track(.imageMediaviewerToggleImageExplanations(imageId: imageID.value, toggleState: .toggleOff))
    }

    func trackShowImageOverlay(imageID: ImageResourceIdentifier) {
        trackingProvider.track(.imageMediaviewerToggleOverlay(imageId: imageID.value, toggleState: .toggleOn))
    }

    func trackHideImageOverlay(imageID: ImageResourceIdentifier) {
        trackingProvider.track(.imageMediaviewerToggleOverlay(imageId: imageID.value, toggleState: .toggleOff))
    }

    func trackShowSmartZoom(imageID: ImageResourceIdentifier) {
        trackingProvider.track(.imageMediaviewerToggleSmartzoom(imageId: imageID.value, toggleState: .toggleOn))
    }

    func trackCloseSmartZoom(imageID: ImageResourceIdentifier) {
        trackingProvider.track(.imageMediaviewerToggleSmartzoom(imageId: imageID.value, toggleState: .toggleOff))
    }

    func trackShowImageMediaviewer(imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?) {
        var media: Tracker.Event.Media.Media?
        var externalAddition: Tracker.Event.Media.ExternalAddition?
        if let imageID = imageID {
            media = Tracker.Event.Media.Media(eid: imageID.value, title: title)
        }
        if let externalAdditionType = externalAdditionType {
            externalAddition = Tracker.Event.Media.ExternalAddition(type: externalAdditionType)
        }
        trackingProvider.track(.imageMediaviewerWasShown(imageId: imageID?.value, media: media, externalAddition: externalAddition, referrer: Tracker.Event.Media.Referrer(articleEid: "")))
    }

    func trackCloseImageMediaviewer(imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?) {
        var media: Tracker.Event.Media.Media?
        var externalAddition: Tracker.Event.Media.ExternalAddition?
        if let imageID = imageID {
            media = Tracker.Event.Media.Media(eid: imageID.value, title: title)
        }
        if let externalAdditionType = externalAdditionType {
            externalAddition = Tracker.Event.Media.ExternalAddition(type: externalAdditionType)
        }
        trackingProvider.track(.imageMediaviewerWasHidden(imageId: imageID?.value, media: media, externalAddition: externalAddition, referrer: Tracker.Event.Media.Referrer(articleEid: "")))
    }

    func trackShowVideoMediaviewer(url: URL) {
        trackingProvider.track(.videoMediaviewerWasShown(mediaUrl: url.absoluteString, referrer: Tracker.Event.Media.Referrer(articleEid: "")))
    }

    func trackNoAccessBuyLicense() {
        trackingProvider.track(.noAccessBuyLicense)
    }
}
