//
//  MediaClient.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 01.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
public protocol MediaClient: AnyObject {
    /// Downloads the file referenced by a given url and returns it as Data.
    ///
    /// - Note: To download files in the background please use
    ///     `Client.downloadFile(at:isUserInitiated:countOfBytesClientExpectsToReceive:)` instead
    ///
    /// - Parameters:
    ///   - url: The url of the file to download.
    ///   - completion: The completion that will be called with either the data, or an error.
    func downloadData(at url: URL, completion: @escaping Completion<Data, NetworkError<EmptyAPIError>>)

    /// This method gets the url to open for a certain feature key.
    /// - Parameters:
    ///   - externalAdditionId: The id of the external addition
    ///   - completion: A completion handler that will be called with result.
    func getExternalAddition(_ externalAdditionId: ExternalAdditionIdentifier, completion: @escaping Completion<ExternalAddition, NetworkError<AccessProtectedError>>)

}
