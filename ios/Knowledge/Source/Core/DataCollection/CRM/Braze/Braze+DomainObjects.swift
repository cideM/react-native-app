//
//  BrazeDomainObjects.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 23.02.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import UIKit
import BrazeKit
import Domain

public enum BrazeStage: Int {
    case preclinic = 1
    case clinic = 2
    case physician = 4

    public func trackingProperty() -> Int {
        self.rawValue
    }
}

public enum BrazeRegion: String {
    case de = "eu"
    case us = "us"

    public func trackingProperty() -> String {
        self.rawValue
    }
}

struct BrazeContentCardDidChangeNotification: AutoNotificationRepresentable {
    let allCards: [BrazeContentCard]
    let displayedCards: [BrazeContentCard]
}

enum BrazeContentCard {
    case captionedImage(BrazeKit.Braze.ContentCard.CaptionedImage, image: UIImage?)
    case classic(BrazeKit.Braze.ContentCard.Classic)

    var id: String {
        switch self {
        case .captionedImage(let card, _): return card.id
        case .classic(let card): return card.id
        }
    }

    var url: URL? {
        switch self {
        case .captionedImage(let card, _):
            return card.clickAction?.url
        case .classic(let card):
            return card.clickAction?.url
        }
    }

    var context: Braze.ContentCard.Context? {
        switch self {
        case .captionedImage(let card, _): return card.data.context
        case .classic(let card): return card.data.context
        }
    }
}

enum BrazeError: Error {
    case unsupportedContentCardType(Braze.ContentCard)
    case invalidContnetCardImageData(URL)
    case failedToDownloadContentCardImage(URL, Error)
}
