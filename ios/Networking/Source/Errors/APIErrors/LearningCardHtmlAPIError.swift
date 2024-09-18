//
//  LearningCardHtmlAPIError.swift
//  Networking
//
//  Created by CSH on 14.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public enum LearningCardHtmlAPIError: Error {
    case learningCardNotFound
}

extension LearningCardHtmlAPIError: GraphQlErrorInstantiatable {
    public init(_  graphQlErrorCode: String?) throws {
        throw GraphQlErrorInstantiationError.unknownGraphQlError
    }
}
