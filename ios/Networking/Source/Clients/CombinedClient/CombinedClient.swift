//
//  CombinedClient.swift
//  Networking
//
//  Created by CSH on 29.10.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

public typealias Completion<ResultType, ErrorType: Error> = (Swift.Result<ResultType, ErrorType>) -> Void

// Note: In the future we can think about adding an extension to the Client protocols defining default cache policies
public final class CombinedClient {

    let restClient: RESTClient
    let graphQlClient: GraphqlClient

    var authorization: Authorization? {
        didSet {
            restClient.setAutToken(authorization?.token)
            graphQlClient.setAuthToken(token: authorization?.token)

            NotificationCenter.default.post(AuthorizationDidChangeNotification(oldValue: oldValue,
                                                                               newValue: authorization),
                                            sender: self)
        }
    }

    /// Initializes a new CombinedClient
    /// - Parameter graphQlURL: The URL of the GraphQL endpoint
    /// - Parameter restURL: The URL of the REST endpoint (excluding the version)
    /// - Parameter authorization: The authorization object of the current user or nil if no user is logged in.
    /// - Parameter applicationIdentifier: The identifier of the current application, that will be transmitted via the User-Agent. For knowledge this is always going to be "AMBOSS-Knowledge"
    public init(graphQlURL: URL,
                restURL: URL,
                authorization: Authorization?,
                applicationIdentifier: String) {

        restClient = RESTClient(baseUrl: restURL,
                                authToken: authorization?.token,
                                userAgent: RESTUserAgent(application: applicationIdentifier))

        graphQlClient = GraphqlClient(url: graphQlURL, authToken: authorization?.token)

        setAuthorization(authorization)
    }

    public func setAuthorization(_ authorization: Authorization?) {
        self.authorization = authorization
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies
        cookies?.forEach { cookieStorage.deleteCookie($0) }
    }

    func postprocess<D, E: Error>(authorization: Authorization?,
                                  completion: @escaping Completion<D, NetworkError<E>>) -> Completion<D, NetworkError<E>> {
        { [weak self] result in
            if let authorization = authorization,
               self?.authorization == authorization,
               case let .failure(error) = result,
               case let .authTokenIsInvalid(developerDescription) = error {
                self?.setAuthorization(nil)
                NotificationCenter.default.post(AuthorizationDidInvalidateNotification(oldAuthorization: authorization, developerDescription: developerDescription), sender: self)
            }

            completion(result)
        }
    }
}
