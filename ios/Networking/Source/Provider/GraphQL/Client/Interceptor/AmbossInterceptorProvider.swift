//
//  AmbossInterceptorProvider.swift
//  Networking
//
//  Created by Elmar Tampe on 21.02.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Apollo
import KnowledgeGraphQLEntities

class AmbossInterceptorProvider: DefaultInterceptorProvider {

    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [any ApolloInterceptor] {
        let customResult: [any ApolloInterceptor] = [TokenInterceptor()] + super.interceptors(for: operation)
        return customResult
    }
}
