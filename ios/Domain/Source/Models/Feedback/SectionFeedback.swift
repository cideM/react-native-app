//
//  FeedbackInputModel.swift
//  Interfaces
//
//  Created by Aamir Suhial Mir on 17.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct SectionFeedback: Codable, Equatable {
    public let message: String
    public let intention: FeedbackIntention
    public let source: Source
    public let mobileInfo: MobileInfo

    // sourcery: fixture:
    public init(message: String, intention: FeedbackIntention, source: Source, mobileInfo: MobileInfo) {
        self.message = message
        self.intention = intention
        self.source = source
        self.mobileInfo = mobileInfo
    }
}

public extension SectionFeedback {
    struct Source: Codable, Equatable {
        public let type: SourceType
        public let id: String?
        public let version: Int?

        // sourcery: fixture:
        public init(type: SourceType = .particle, id: String?, version: Int?) {
            self.type = type
            self.id = id
            self.version = version
        }
    }

    struct MobileInfo: Codable, Equatable {
        public let appPlatform: AppPlatform
        public let appName: AppName
        public let appVersion: String
        public let archiveVersion: Int

        // sourcery: fixture:
        public init(appPlatform: AppPlatform = .ios, appName: AppName, appVersion: String, archiveVersion: Int) {
            self.appPlatform = appPlatform
            self.appName = appName
            self.appVersion = appVersion
            self.archiveVersion = archiveVersion
        }
    }
}

public extension SectionFeedback.Source {
    // sourcery: fixture:
    enum SourceType: String, Codable {
        case particle
    }
}

public extension SectionFeedback.MobileInfo {
    // sourcery: fixture:
    enum AppPlatform: String, Codable {
        case ios
    }

    // sourcery: fixture:
    enum AppName: String, Codable {
        case knowledge
        case wissen
    }
}
