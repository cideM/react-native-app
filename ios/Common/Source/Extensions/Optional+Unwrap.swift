//  Optional+Unwrap.swift
//  Common
//
//  Created by Roberto Seidenberg on 24.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

public extension Optional where Wrapped: Collection {
    var isNonEmpty: Bool {
        guard let object = self else { return false }
        return !object.isEmpty
    }
}
