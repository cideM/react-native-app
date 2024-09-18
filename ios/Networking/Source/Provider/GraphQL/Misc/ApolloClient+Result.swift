//
//  ApolloClient+Result.swift
//  Networking
//
//  Created by CSH on 13.05.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Apollo
import Common
import Domain
import KnowledgeGraphQLEntities

public extension ApolloClient {
    @discardableResult func fetch<Query: GraphQLQuery, APIError: GraphQlErrorInstantiatable>(query: Query,
                                                                                             cachePolicy: CachePolicy = .fetchIgnoringCacheCompletely,
                                                                                             resultHandler: @escaping (Swift.Result<Query.Data, NetworkError<APIError>>) -> Void) -> Cancelable {

        _ = fetch(query: query, cachePolicy: cachePolicy) { result in
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    do {
                        if let notAuthorizedError = errors.first(where: { $0.message == "permission.user_is_not_authorized" }) {
                            resultHandler(.failure(.authTokenIsInvalid("Request for \(query) returned \(notAuthorizedError)")))
                        } else {
                            let apiErrors = try errors.map { graphQLError in
                                try APIError(graphQLError.message)
                            }
                            let error = NetworkError<APIError>.apiResponseError(apiErrors)
                            resultHandler(.failure(error))
                        }
                    } catch {
                        let error = NetworkError<APIError>.other("Unknown API response error: \(errors)")
                        resultHandler(.failure(error))
                    }
                } else if let data = graphQLResult.data {
                    resultHandler(.success(data))
                } else {
                    let error = NetworkError<APIError>.other("Apollo returned neither an error nor any data. This is likely an error within Apollo.")
                    resultHandler(.failure(error))
                }
            case .failure(let error):
                let networkError = NetworkErrorConverter<APIError>.networkError(from: error)
                resultHandler(.failure(networkError))
            }
        }

        return ClosureCancelable {
            // HOTFIX: These right now are all cancelled, since nobody is keeping a reference to them
            // cancellable.cancel()
        }
    }

    @discardableResult func perform<Mutation: GraphQLMutation, APIError: GraphQlErrorInstantiatable>(mutation: Mutation,
                                                                                                     resultHandler: @escaping (Swift.Result<Mutation.Data, NetworkError<APIError>>) -> Void) -> Cancelable {
        _ = perform(mutation: mutation) { result in
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    do {
                        if let notAuthorizedError = errors.first(where: { $0.message == "permission.user_is_not_authorized" }) {
                            resultHandler(.failure(.authTokenIsInvalid("Request for \(mutation) returned \(notAuthorizedError)")))
                        } else {
                            let apiErrors = try errors.map { graphQLError in
                                try APIError(graphQLError.message)
                            }
                            let error = NetworkError<APIError>.apiResponseError(apiErrors)
                            resultHandler(.failure(error))
                        }
                    } catch {
                        let error = NetworkError<APIError>.other("Unknown API response error: \(errors)")
                        resultHandler(.failure(error))
                    }
                } else if let data = graphQLResult.data {
                    resultHandler(.success(data))
                } else {
                    let error = NetworkError<APIError>.other("Apollo returned neither an error nor any data. This is likely an error within Apollo.")
                    resultHandler(.failure(error))
                }
            case .failure(let error):
                let networkError = NetworkErrorConverter<APIError>.networkError(from: error)
                resultHandler(.failure(networkError))
            }
        }

        return ClosureCancelable {
            // HOTFIX: These right now are all cancelled, since nobody is keeping a reference to them
            // cancellable.cancel()
        }
    }
}
