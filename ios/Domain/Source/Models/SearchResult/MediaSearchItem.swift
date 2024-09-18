//
//  MediaItem.swift
//  Interfaces
//
//  Created by Merve Kavaklioglu on 29.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct MediaSearchItem: Equatable {
    public let mediaId: String
    public let title: String
    public let url: URL
    public let externalAddition: ExternalAddition?
    public let category: MediaSearchItem.Category
    public let typeName: String
    public let resultUUID: String
    public let targetUUID: String

    // sourcery: fixture:
    public init(mediaId: String,
                title: String,
                url: URL,
                externalAddition: ExternalAddition?,
                category: MediaSearchItem.Category,
                typeName: String,
                resultUUID: String,
                targetUUID: String) {
        self.mediaId = mediaId
        self.title = title
        self.url = url
        self.externalAddition = externalAddition
        self.category = category
        self.typeName = typeName
        self.resultUUID = resultUUID
        self.targetUUID = targetUUID
    }

    // sourcery: fixture:
    public enum Category: Equatable {
        case flowchart
        case illustration
        case photo
        case imaging
        case chart
        case microscopy
        case audio
        case auditor
        case video
        case calculator
        case webContent
        case meditricks
        case smartzoom
        case effigos
        case other(String)
    }
}

public extension MediaSearchItem {
    struct ExternalAddition: Equatable {
        public let type: Domain.ExternalAddition.Types
        public let url: URL

        // sourcery: fixture:
        public init(type: Domain.ExternalAddition.Types, url: URL) {
            self.type = type
            self.url = url
        }
    }
}
