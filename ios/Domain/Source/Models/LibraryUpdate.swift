//
//  CheckForLibraryUpdatesResult.swift
//  Interfaces
//
//  Created by Aamir Suhial Mir on 10.12.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

// sourcery: fixture:
public struct LibraryUpdate: Equatable, Codable {
    public let version: Int
    public let url: URL
    public let updateMode: LibraryUpdateMode
    public let size: Int
    public let createdAt: Date

    // sourcery: fixture:
    public init(version: Int, url: URL, updateMode: LibraryUpdateMode, size: Int, createdAt: Date) {
        self.version = version
        self.url = url
        self.updateMode = updateMode
        self.size = size
        self.createdAt = createdAt
    }
}

// sourcery: fixture:
public enum LibraryUpdateMode: String, Codable {
    case should
    case must
    case can
}
