//
//  ImageReference.swift
//  Interfaces
//
//  Created by Silvio Bulla on 03.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct ImageReference: Codable {
    public let source: URL
    public let width: Int
    public let height: Int
    public let filesize: Int
    public let mimeType: String

    enum ImageReferenceCodingKeys: String, CodingKey {
        case source
        case width
        case height
        case filesize
        case mimeType = "mime_type"
    }

    // sourcery: fixture:
    init(source: URL, width: Int, height: Int, filesize: Int, mimeType: String) {
        self.source = source
        self.width = width
        self.height = height
        self.filesize = filesize
        self.mimeType = mimeType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ImageReferenceCodingKeys.self)
        let sourceString = try container.decode(String.self, forKey: .source)
        if let source = URL(string: sourceString) {
            self.source = source
        } else {
            throw DecodingError.dataCorruptedError(forKey: .source, in: container, debugDescription: "Source is not a valid url")
        }
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        filesize = try container.decode(Int.self, forKey: .filesize)
        mimeType = try container.decode(String.self, forKey: .mimeType)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ImageReferenceCodingKeys.self)
        try container.encode(source.absoluteString, forKey: .source)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(filesize, forKey: .filesize)
        try container.encode(mimeType, forKey: .mimeType)
    }
}
