//
//  SearchMonographContentTreeNodeType.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 12.06.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation
import KnowledgeGraphQLEntities

protocol SearchMonographContentTreeNodeType {
    var fields: AmbossSubstanceNodeFields { get }
    var childNodes: [SearchMonographContentTreeNodeType] { get }
}
