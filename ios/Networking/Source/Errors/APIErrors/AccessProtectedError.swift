//
//  AccessProtectedError.swift
//  Networking
//
//  Created by CSH on 17.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public enum AccessProtectedError: Error {
    case accessBlocked
}

extension AccessProtectedError: GraphQlErrorInstantiatable {
    public init(_  graphQlErrorCode: String?) throws {
        throw GraphQlErrorInstantiationError.unknownGraphQlError
    }
}
