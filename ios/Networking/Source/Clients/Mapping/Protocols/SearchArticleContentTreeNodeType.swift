//
//  SearchArticleContentTreeNodeType.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 12.06.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation
import KnowledgeGraphQLEntities

protocol SearchArticleContentTreeNodeType {
    var fields: ArticleNodeFields { get }
    var childNodes: [SearchArticleContentTreeNodeType] { get }
}
