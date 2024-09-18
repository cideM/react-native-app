//
//  Error.swift
//  Contentful
//
//  Created by Boris Bügling on 29/09/15.
//  Copyright © 2015 Contentful GmbH. All rights reserved.
//

import Foundation

/// Possible errors being thrown by the SDK
public enum SDKError: Error, CustomDebugStringConvertible {

    /// Thrown when receiving an invalid HTTP response.
    /// - Parameter response: Optional URL response that has triggered the error.
    case invalidHTTPResponse(response: URLResponse?)

    /// Thrown when attempting to construct an invalid URL.
    /// - Parameter string: The invalid URL string.
    case invalidURL(string: String)

    /// Thrown if the subsequent sync operations are executed in preview mode.
    case previewAPIDoesNotSupportSync

    /// Thrown when receiving unparseable JSON responses.
    /// - Parameters:
    ///   - data: The data being parsed.
    ///   - errorMessage: The message from the error which occured during parsing.
    case unparseableJSON(data: Data?, errorMessage: String)

    /// Thrown when no resource is found matching a specified id
    case noResourceFoundFor(id: String)

    /// Thrown when a `Foundation.Data` object is unable to be transformed to a `UIImage` or an `NSImage` object.
    case unableToDecodeImageData

    /// Thrown when the SDK has issues mapping responses with the necessary locale information.
    /// - Parameter message: The message from the erorr which occured during parsing.
    case localeHandlingError(message: String)

    public var debugDescription: String {
        return message
    }

    internal var message: String {
        switch self {
        case .invalidHTTPResponse(let response):
            return "The HTTP request returned a corrupted HTTP response: \(response.debugDescription)"
        case .invalidURL(let string):
            return string
        case .previewAPIDoesNotSupportSync:
            return "The Content Preview API does not support subsequent sync operations."
        case .unparseableJSON(_, let errorMessage):
            return errorMessage
        case .noResourceFoundFor(let id):
            return "No resource was found with the id: \(id)"
        case .unableToDecodeImageData:
            return "The binary data returned was not convertible to a native UIImage or NSImage"
        case .localeHandlingError(let message):
            return message
        }
    }
}
