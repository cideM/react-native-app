//
//  NetworkErrorConverter.swift
//  Networking
//
//  Created by Mohamed Abdul-Hameed on 9/10/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Apollo
import Foundation

enum NetworkErrorConverter<T: Error> {
    static func networkError(from error: Error) -> NetworkError<T> {
        switch error {
        case let urlError as URLError: return NetworkErrorConverter<T>.networkError(from: urlError)
        case let decodingError as DecodingError: return NetworkErrorConverter<T>.networkError(from: decodingError)
        case let restError as RESTError: return NetworkErrorConverter<T>.networkError(from: restError)
        case let apolloURLSessionClientError as URLSessionClient.URLSessionClientError: return NetworkErrorConverter<T>.networkError(from: apolloURLSessionClientError)
        default: return .other("Unknown error: \(error)")
        }
    }

    private static func networkError(from error: URLError) -> NetworkError<T> {
        switch error.code {
        case .timedOut:
            return .requestTimedOut
        case .notConnectedToInternet, .networkConnectionLost, .secureConnectionFailed:
            return .noInternetConnection
        default:
            return .other("Something went wrong with the Internet connection. Error code is: \(error.code).", code: error.code)
        }
    }

    private static func networkError(from error: DecodingError) -> NetworkError<T> {
        switch error {
        case .dataCorrupted(let context):
            return .invalidFormat("Data corrupted. Context: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            return .invalidFormat("Key '\(key)' not found. Context: \(context.debugDescription)")
        case .typeMismatch(let type, let context):
            return .invalidFormat("Type '\(type)' mismatch. Context: \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            return .invalidFormat("Value if type '\(type)' not found. Context: \(context.debugDescription)")
        @unknown default:
            return .other("Unknown decoding error")
        }
    }

    private static func networkError(from error: URLSessionClient.URLSessionClientError) -> NetworkError<T> {
        switch error {
        case let .networkError(_, _, urlError):
            return networkError(from: urlError)
        default:
            return .other("Unknown URLSessionClientError \(error)")
        }
    }

    private static func networkError(from error: RESTError) -> NetworkError<T> {
        switch error {
        case .invalidAuthorization: return .authTokenIsInvalid("")
        }
    }
}
