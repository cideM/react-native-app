//
//  PharmaUpdate.swift
//  Knowledge
//
//  Created by Silvio Bulla on 30.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct PharmaUpdate: Equatable {
    public let version: Version
    public let size: Int
    public let zippedSize: Int
    public let url: URL
    public let dateCreated: Date

    let iso8601DateFormatter = ISO8601DateFormatter()

    // sourcery: fixture:
    public init(version: Version, size: Int, zippedSize: Int, url: URL, date: Date) {
        self.version = version
        self.size = size
        self.zippedSize = zippedSize
        self.url = url
        self.dateCreated = date
    }

    public init?(version: Version, size: Int, zippedSize: Int, url: String, dateCreated: String) {
        guard let date = iso8601DateFormatter.date(from: dateCreated), let url = URL(string: url) else { return nil }
        self.version = version
        self.size = size
        self.zippedSize = zippedSize
        self.url = url
        self.dateCreated = date
    }
}

public struct Version {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public var stringRepresentation: String {
        "\(major).\(minor).\(patch)"
    }

    // sourcery: fixture:
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

extension Version: Comparable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.stringRepresentation.compare(rhs.stringRepresentation, options: .numeric) == .orderedSame
    }

    public static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.stringRepresentation.compare(rhs.stringRepresentation, options: .numeric) == .orderedDescending
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.stringRepresentation.compare(rhs.stringRepresentation, options: .numeric) == .orderedAscending
    }
}
