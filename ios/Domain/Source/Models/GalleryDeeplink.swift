//
//  GalleryDeeplink.swift
//  Interfaces
//
//  Created by CSH on 02.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct GalleryDeeplink {
    public let gallery: GalleryIdentifier
    public let imageOffset: Int

    // sourcery: fixture:
    public init(gallery: GalleryIdentifier, imageOffset: Int) {
        self.gallery = gallery
        self.imageOffset = imageOffset
    }
}
