//
//  LibraryUpdaterState.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 27.12.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

typealias Progress = Double

enum LibraryUpdaterState {
    case upToDate
    case checking(isUserTriggered: Bool)
    case downloading(LibraryUpdate, Progress, isUserTriggered: Bool)
    case installing(libraryUpdate: LibraryUpdate, libraryZipFileName: String)
    case failed(LibraryUpdate, LibraryUpdateError) // When encoding the LibraryUpdaterState, the `failed` state is converted to an `upToDate` state. The reasoning behind that is that once the app is launched it will automatically try to run the update again and if it failed the error will be automatically displayed in the appropriate way.

    var isUserTriggered: Bool {
        switch self {
        case .upToDate: return false
        case .checking(let isUserTriggered): return isUserTriggered
        case .downloading(_, _, let isUserTriggered): return isUserTriggered
        case .installing: return false
        case .failed: return false
        }
    }
}

extension LibraryUpdaterState: Codable {

    enum Kind: String, Codable {
        case upToDate
        case updating
        case installing
    }

    enum CodingKeys: String, CodingKey {
        case kind
        case isUserTriggered
        case update
        case libraryTmpFileName
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .upToDate:
            self = .upToDate
        case .installing:
            let update = try container.decode(LibraryUpdate.self, forKey: .update)
            let libraryTmpFileName = try container.decode(String.self, forKey: .libraryTmpFileName)
            self = .installing(libraryUpdate: update, libraryZipFileName: libraryTmpFileName)
        case .updating:
            let isUserTriggered = try container.decode(Bool.self, forKey: .isUserTriggered)
            let update = try container.decode(LibraryUpdate.self, forKey: .update)
            self = .downloading(update, 0, isUserTriggered: isUserTriggered)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .upToDate, .checking, .failed:
            try container.encode(Kind.upToDate, forKey: .kind)
        case .installing(let update, let libraryTmpFileName):
            try container.encode(Kind.installing, forKey: .kind)
            try container.encode(update, forKey: .update)
            try container.encode(libraryTmpFileName, forKey: .libraryTmpFileName)
        case .downloading(let update, _, let isUserTriggered):
            try container.encode(Kind.updating, forKey: .kind)
            try container.encode(isUserTriggered, forKey: .isUserTriggered)
            try container.encode(update, forKey: .update)
        }
    }
}
