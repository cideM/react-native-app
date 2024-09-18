//
//  ImageResource.swift
//  Interfaces
//
//  Created by Silvio Bulla on 02.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public typealias ImageResourceIdentifier = Identifier<ImageResourceType, String>

public struct ImageResourceType {
    public let title: String?
    public let description: String
    public let copyright: String
    public let standardImages: [ImageReference]
    public let overlayImages: [ImageReference]
    public let externalAdditions: [ExternalAddition]
    public let imageResourceIdentifier: ImageResourceIdentifier

    // sourcery: fixture:
    init(title: String?, description: String, copyright: String, thumbnailImages: [ImageReference], standardImages: [ImageReference], overlayImages: [ImageReference], externalAdditions: [ExternalAddition], imageResourceIdentifier: ImageResourceIdentifier) {
        self.title = title
        self.description = description
        self.copyright = copyright
        self.standardImages = standardImages
        self.overlayImages = overlayImages
        self.externalAdditions = externalAdditions
        self.imageResourceIdentifier = imageResourceIdentifier
    }
}

extension ImageResourceType: Codable {
    // unused:ignore CodingKeys
    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case copyright
        case standardImages = "standard_images"
        case overlayImages = "overlay_images"
        case externalAdditions = "feature_keys"
        case imageResourceIdentifier = "id"
    }
}
