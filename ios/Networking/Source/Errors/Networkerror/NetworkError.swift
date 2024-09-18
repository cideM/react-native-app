//
//  NetworkError.swift
//  Networking
//
//  Created by CSH on 13.05.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// This enum describes all error cases for network requests
/// that should be handled by the app in any specific way.
/// The Generic `T` defines the type of the associated value of `apiResponseError`. For example, the `NetworkError` in case of the login end point will be `NetworkError<LoginAPIError>`.
public enum NetworkError<T: Error>: Error {
    /// The device is currently offline or no connection to the server could be established.
    case noInternetConnection

    /// The request timed out.
    case requestTimedOut

    /// The server responded with an error code that can be interpeted by the client.
    case failed(code: String)

    /// The user is currently not authorized to perform this request.
    case authTokenIsInvalid(_ developerDescription: String)

    /// An error occured while parsing a returned object. For example, the contract is to return a User object that has a field called `username`, and the backend returned the field as `user_name`.
    case invalidFormat(_ developerDescription: String)

    /// Any error returned from the end point, like for example, invalid credentials for a login end point. The possible cases for the API error are restricted by `T`. In case of a login end point we have `LoginAPIError`.
    case apiResponseError([T])

    /// Other errors, either app or backend errors; Cannot be resolved by the user.
    /// Possible cases are:
    ///     - invalid server response
    case other(_ developerDescription: String, code: URLError.Code? = nil)
}
