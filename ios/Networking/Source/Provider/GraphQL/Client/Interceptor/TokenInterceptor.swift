//
//  TokenInterceptor.swift
//  Networking
//
//  Created by Elmar Tampe on 21.02.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Apollo
import KnowledgeGraphQLEntities

class TokenInterceptor: ApolloInterceptor {

    var id: String = UUID().uuidString
    let store = AmbossInterceptorProviderStore.sharedInstance

    func interceptAsync<Operation>(chain: Apollo.RequestChain,
                                   request: Apollo.HTTPRequest<Operation>,
                                   response: Apollo.HTTPResponse<Operation>?,
                                   completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void) where Operation: ApolloAPI.GraphQLOperation {

        if let token = store.authToken {
            request.addHeader(name: "Authorization", value: "Bearer \(token)")
        }

        chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)
    }
}
