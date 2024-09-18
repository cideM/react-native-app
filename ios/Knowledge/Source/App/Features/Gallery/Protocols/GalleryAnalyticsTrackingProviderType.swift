//
//  GalleryAnalyticsTrackingProviderType.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 18.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

/// @mockable
protocol GalleryAnalyticsTrackingProviderType {
    func trackShowImageExplanations(imageID: ImageResourceIdentifier)
    func trackHideImageExplanations(imageID: ImageResourceIdentifier)

    func trackShowImageOverlay(imageID: ImageResourceIdentifier)
    func trackHideImageOverlay(imageID: ImageResourceIdentifier)

    func trackShowSmartZoom(imageID: ImageResourceIdentifier)
    func trackCloseSmartZoom(imageID: ImageResourceIdentifier)

    func trackShowImageMediaviewer(imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?)
    func trackCloseImageMediaviewer(imageID: ImageResourceIdentifier?, title: String?, externalAdditionType: String?)

    func trackShowVideoMediaviewer(url: URL)

    func trackNoAccessBuyLicense()
}

extension GalleryAnalyticsTrackingProviderType {

    func trackShowImageMediaviewer(externalAdditionType: String?) {
        trackShowImageMediaviewer(imageID: nil, title: nil, externalAdditionType: externalAdditionType)
    }

    func trackCloseImageMediaviewer(externalAdditionType: String?) {
        trackCloseImageMediaviewer(imageID: nil, title: nil, externalAdditionType: externalAdditionType)
    }

    func trackShowImageMediaviewer(imageID: ImageResourceIdentifier?, title: String?) {
        trackShowImageMediaviewer(imageID: imageID, title: title, externalAdditionType: nil)
    }

    func trackCloseImageMediaviewer(imageID: ImageResourceIdentifier?, title: String?) {
        trackCloseImageMediaviewer(imageID: imageID, title: title, externalAdditionType: nil)
    }
}
