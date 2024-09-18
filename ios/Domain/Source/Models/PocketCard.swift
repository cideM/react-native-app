//
//  PocketCard.swift
//  Domain
//
//  Created by Roberto Seidenberg on 02.07.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct PocketCard {

    public let groups: [Group]

    // sourcery: fixture:
    public init(groups: [PocketCard.Group]) {
        self.groups = groups
    }

    public struct Group {

        public let title: String
        public let anchor: String
        public let sections: [Section]

        // sourcery: fixture:
        public  init(title: String, anchor: String, sections: [PocketCard.Section]) {
            self.title = title
            self.anchor = anchor
            self.sections = sections
        }
    }

    public struct Section {

        public let title: String
        public let anchor: String
        public let content: String

        // sourcery: fixture:
        public init(title: String, anchor: String, content: String) {
            self.title = title
            self.anchor = anchor
            self.content = content
        }
    }
}
