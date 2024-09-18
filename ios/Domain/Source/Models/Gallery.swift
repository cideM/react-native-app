//
//  Gallery.swift
//  Interfaces
//
//  Created by CSH on 03.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public typealias GalleryIdentifier = Identifier<Gallery, String>

public struct Gallery {
    public let id: GalleryIdentifier
    private let sortableImages: [SortableImageReference]
    public var images: [ImageResourceIdentifier] {
        sortableImages
            .sorted { $0.imageIndex < $1.imageIndex }
            .map { $0.imageResource }
    }

    // sourcery: fixture:
    init(id: GalleryIdentifier, sortableImages: [SortableImageReference]) {
        self.id = id
        self.sortableImages = sortableImages
    }
}

extension Gallery: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case id
        case sortableImages = "images"
    }
}

internal extension Gallery {
    struct SortableImageReference: Codable, Equatable {
        var imageIndex: Int {
            Int(imageIndexString) ?? 0
        }
        private let imageIndexString: String
        let imageResource: ImageResourceIdentifier

        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case imageIndex = "image_index"
            case imageResource = "image_resource"
        }

        // swiftlint:disable:next nesting
        private enum ImageResourceCodingKeys: String, CodingKey {
            case id
        }

        init(imageIndex: String, imageResource: ImageResourceIdentifier) {
            self.imageIndexString = imageIndex
            self.imageResource = imageResource
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            imageIndexString = try container.decode(String.self, forKey: .imageIndex)

            let imageResourceContainer = try container.nestedContainer(keyedBy: ImageResourceCodingKeys.self, forKey: .imageResource)
            imageResource = try imageResourceContainer.decode(ImageResourceIdentifier.self, forKey: .id)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(imageIndexString, forKey: .imageIndex)

            var imageResourceContainer = container.nestedContainer(keyedBy: ImageResourceCodingKeys.self, forKey: .imageResource)
            try imageResourceContainer.encode(imageResource, forKey: .id)
        }
    }
}
