//
//  SnippetClient.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 01.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
public protocol SnippetClient: AnyObject {

    /// This method return a snippet for a specific snippet identifier
    /// - Parameters:
    ///   - snippetIdentifier: The snippet  identifier we are requesting data for.
    ///   - completion: A completion handler that will be called with result.
    func getSnippet(for snippetIdentifier: SnippetIdentifier, cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<Snippet, NetworkError<EmptyAPIError>>)
}
