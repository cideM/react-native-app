//
//  MinimapNodeMeta.swift
//  Interfaces
//
//  Created by Aamir Suhial Mir on 01.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct MinimapNodeMeta: Codable, Equatable {
    public let title: String
    public let anchor: LearningCardSectionIdentifier
    public let childNodes: [MinimapNodeMeta]
    public let requiredModes: [String]

    // sourcery: fixture:
    public init(title: String, anchor: LearningCardSectionIdentifier, childNodes: [MinimapNodeMeta], requiredModes: [String]) {
        self.title = title
        self.anchor = anchor
        self.childNodes = childNodes
        self.requiredModes = requiredModes
    }
}

extension MinimapNodeMeta {
    enum CodingKeys: String, CodingKey {
        case title
        case anchor
        case childNodes = "child_nodes"
        case requiredModes = "display_requirements"
    }
}
