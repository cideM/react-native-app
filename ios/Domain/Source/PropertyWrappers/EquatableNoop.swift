//
//  EquatableNoop.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 19.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

/// This property wrapper can be used to exclude a property from `Equatable` protocol conformance.
///
/// This helps us keep utilising the Synthesized Equatables, hence avoiding the need to implement the `==` operator function which is error-prone and hard to maintain especially when adding new properties in the future.
@propertyWrapper
public struct EquatableNoop<Value>: Equatable {
    public var wrappedValue: Value

    public static func == (lhs: EquatableNoop<Value>, rhs: EquatableNoop<Value>) -> Bool {
        true
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}
