//
//  SearchMonographContentTreeNodeType.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 12.06.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation
import KnowledgeGraphQLEntities

extension SearchMonographResultsQuery.Data.SearchAmbossSubstanceResults.Edge.Node: SearchMonographContentTreeNodeType {

    var fields: AmbossSubstanceNodeFields {
        fragments.ambossSubstanceNodeFields
    }

    var childNodes: [SearchMonographContentTreeNodeType] {
        children
    }
}

extension SearchMonographResultsQuery.Data.SearchAmbossSubstanceResults.Edge.Node.Child: SearchMonographContentTreeNodeType {

    var fields: AmbossSubstanceNodeFields {
        fragments.ambossSubstanceNodeFields
    }

    var childNodes: [SearchMonographContentTreeNodeType] {
        children
    }
}

extension SearchMonographResultsQuery.Data.SearchAmbossSubstanceResults.Edge.Node.Child.Child: SearchMonographContentTreeNodeType {

    var fields: AmbossSubstanceNodeFields {
        fragments.ambossSubstanceNodeFields
    }

    var childNodes: [SearchMonographContentTreeNodeType] {
        children
    }
}

extension SearchMonographResultsQuery.Data.SearchAmbossSubstanceResults.Edge.Node.Child.Child.Child: SearchMonographContentTreeNodeType {

    var fields: AmbossSubstanceNodeFields {
        fragments.ambossSubstanceNodeFields
    }

    var childNodes: [SearchMonographContentTreeNodeType] {
        []
    }
}

extension SearchOverviewResultsQuery.Data.SearchAmbossSubstanceResults.Edge.Node: SearchMonographContentTreeNodeType {

    var fields: AmbossSubstanceNodeFields {
        fragments.ambossSubstanceNodeFields
    }

    var childNodes: [SearchMonographContentTreeNodeType] {
        children
    }
}

extension SearchOverviewResultsQuery.Data.SearchAmbossSubstanceResults.Edge.Node.Child: SearchMonographContentTreeNodeType {

    var fields: AmbossSubstanceNodeFields {
        fragments.ambossSubstanceNodeFields
    }

    var childNodes: [SearchMonographContentTreeNodeType] {
        children
    }
}

extension SearchOverviewResultsQuery.Data.SearchAmbossSubstanceResults.Edge.Node.Child.Child: SearchMonographContentTreeNodeType {

    var fields: AmbossSubstanceNodeFields {
        fragments.ambossSubstanceNodeFields
    }

    var childNodes: [SearchMonographContentTreeNodeType] {
        children
    }
}

extension SearchOverviewResultsQuery.Data.SearchAmbossSubstanceResults.Edge.Node.Child.Child.Child: SearchMonographContentTreeNodeType {

    var fields: AmbossSubstanceNodeFields {
        fragments.ambossSubstanceNodeFields
    }

    var childNodes: [SearchMonographContentTreeNodeType] {
        []
    }
}
