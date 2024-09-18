//
//  FeedbackDeeplink.swift
//  Interfaces
//
//  Created by Aamir Suhial Mir on 23.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct FeedbackDeeplink {
    public let anchor: LearningCardAnchorIdentifier?
    public let version: Int?
    public let archiveVersion: Int

    // sourcery: fixture:
    public init(anchor: LearningCardAnchorIdentifier?, version: Int?, archiveVersion: Int) {
        self.anchor = anchor
        self.version = version
        self.archiveVersion = archiveVersion
    }
}
