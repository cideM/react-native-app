//
//  LearningCardTreeItem.swift
//  Interfaces
//
//  Created by CSH on 27.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct LearningCardTreeItem {
    /// The reference of this CardTreeItem. This can be used to find children of this element
    public let id: Int
    /// The id of the parent item. This is a root element if nil.
    public let parent: Int?
    /// The title of the item
    public let title: String
    /// The xid of the LearningCard. If nil, this isn't referencing a learning card.
    public let learningCardIdentifier: LearningCardIdentifier?
    /// The number of children. If nil, there are no children.
    public let childrenCount: Int?

    // sourcery: fixture:
    public init(id: Int, parent: Int?, title: String, learningCardIdentifier: LearningCardIdentifier?, childrenCount: Int?) {
        self.id = id
        self.parent = parent
        self.title = title
        self.learningCardIdentifier = learningCardIdentifier
        self.childrenCount = childrenCount
    }
}

extension LearningCardTreeItem: Codable, Equatable {

    enum LearningCardTreeItemCodingKeys: String, CodingKey {
        case id
        case parent
        case title
        case xid
        case childrenCount = "children_count"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LearningCardTreeItemCodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        let parentValue = try container.decode(Int.self, forKey: .parent)
        if parentValue != 0 {
            // a parent value of 0 means there is no parent
            parent = parentValue
        } else {
            parent = nil
        }
        title = try container.decode(String.self, forKey: .title)
        childrenCount = try? container.decode(Int.self, forKey: .childrenCount)
        if let xidString = try? container.decode(String.self, forKey: .xid) {
            learningCardIdentifier = LearningCardIdentifier(xidString)
        } else {
            learningCardIdentifier = nil
        }
    }
}
