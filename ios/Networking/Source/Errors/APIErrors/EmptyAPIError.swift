//
//  EmptyAPIError.swift
//  Networking
//
//  Created by CSH on 12.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// The EmptyAPIError can be used, if no Endpoint specific error can be expected.
public enum EmptyAPIError: Error {}

extension EmptyAPIError: GraphQlErrorInstantiatable {
    public init(_  graphQlErrorCode: String?) throws {
        throw GraphQlErrorInstantiationError.unknownGraphQlError
    }
}
