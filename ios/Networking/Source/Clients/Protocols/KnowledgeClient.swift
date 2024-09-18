//
//  KnowledgeClient.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 01.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
public protocol KnowledgeClient: AnyObject { // App Client

    /// This method fetches the list of deprecated versions
    /// - Parameter completion: A completion handler that will be called with result.
    func getDeprecationList(_ completion: @escaping Completion<[DeprecationItem], NetworkError<EmptyAPIError>>)

}
