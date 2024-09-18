//
//  GraphQLError.swift
//  Networking
//
//  Created by Elmar Tampe on 20.02.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation

public protocol GraphQlErrorInstantiatable: Error {
    init(_ graphQlErrorCode: String?) throws
}

enum GraphQlErrorInstantiationError: Error {
    case unknownGraphQlError
}
