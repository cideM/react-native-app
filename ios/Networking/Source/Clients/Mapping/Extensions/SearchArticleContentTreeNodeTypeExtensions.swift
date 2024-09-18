//
//  SearchArticleContentTreeNodeTypeExtensions.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 12.06.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import KnowledgeGraphQLEntities

extension SearchArticleResultsQuery.Data.SearchArticleContentTree.Edge.Node: SearchArticleContentTreeNodeType {

    var fields: ArticleNodeFields {
        fragments.articleNodeFields
    }

    var childNodes: [SearchArticleContentTreeNodeType] {
        children
    }
}

extension SearchArticleResultsQuery.Data.SearchArticleContentTree.Edge.Node.Child: SearchArticleContentTreeNodeType {

    var fields: ArticleNodeFields {
        fragments.articleNodeFields
    }

    var childNodes: [SearchArticleContentTreeNodeType] {
        children
    }
}

extension SearchArticleResultsQuery.Data.SearchArticleContentTree.Edge.Node.Child.Child: SearchArticleContentTreeNodeType {

    var fields: ArticleNodeFields {
        fragments.articleNodeFields
    }

    var childNodes: [SearchArticleContentTreeNodeType] {
        children
    }
}

extension SearchArticleResultsQuery.Data.SearchArticleContentTree.Edge.Node.Child.Child.Child: SearchArticleContentTreeNodeType {
    var fields: ArticleNodeFields {
        fragments.articleNodeFields
    }

    var childNodes: [SearchArticleContentTreeNodeType] {
        []
    }
}

extension SearchOverviewResultsQuery.Data.SearchArticleContentTree.Edge.Node: SearchArticleContentTreeNodeType {
    var fields: ArticleNodeFields {
        fragments.articleNodeFields
    }

    var childNodes: [SearchArticleContentTreeNodeType] {
        children
    }
}

extension SearchOverviewResultsQuery.Data.SearchArticleContentTree.Edge.Node.Child: SearchArticleContentTreeNodeType {
    var fields: ArticleNodeFields {
        fragments.articleNodeFields
    }

    var childNodes: [SearchArticleContentTreeNodeType] {
        children
    }
}

extension SearchOverviewResultsQuery.Data.SearchArticleContentTree.Edge.Node.Child.Child: SearchArticleContentTreeNodeType {
    var fields: ArticleNodeFields {
        fragments.articleNodeFields
    }

    var childNodes: [SearchArticleContentTreeNodeType] {
        children
    }
}

extension SearchOverviewResultsQuery.Data.SearchArticleContentTree.Edge.Node.Child.Child.Child: SearchArticleContentTreeNodeType {
    var fields: ArticleNodeFields {
        fragments.articleNodeFields
    }

    var childNodes: [SearchArticleContentTreeNodeType] {
        []
    }
}
