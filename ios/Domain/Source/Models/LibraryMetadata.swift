//
//  LibraryMetadata.swift
//  Interfaces
//
//  Created by CSH on 21.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct LibraryMetadata: Codable {
    /// The identifier of the library. This identifier is then used in most network calls to reference a specific library archive.
    public let versionId: Int
    /// Defines if this library contains the html for learning cards / is a full archive
    public let containsLearningCardContent: Bool
    /// The date this version of the library was created
    public var createdAt: Date?
    public var isDarkModeSupported: Bool

    // sourcery: fixture: versionId="0"
    public init(versionId: Int, containsLearningCardContent: Bool, createdAt: Date?, isDarkModeSupported: Bool) {
        self.versionId = versionId
        self.containsLearningCardContent = containsLearningCardContent
        self.createdAt = createdAt
        self.isDarkModeSupported = isDarkModeSupported
    }

    public init(versionString: String, containsLearningCardContent: Bool, createdAt: Date?, isDarkModeSupported: Bool) {
        let versionId: Int
        if let vVersionSubstring = versionString.split(separator: "_").first,
            let versionSubstring = String(vVersionSubstring).split(separator: "v").last {
            versionId = Int(String(versionSubstring)) ?? 0
        } else {
            versionId = 0
        }

        self.versionId = versionId
        self.containsLearningCardContent = containsLearningCardContent
        self.createdAt = createdAt
        self.isDarkModeSupported = isDarkModeSupported
    }
}
