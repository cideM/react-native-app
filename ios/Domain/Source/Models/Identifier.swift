//
//  Identifier.swift
//  Interfaces
//
//  Created by CSH on 22.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct Identifier<Identified, RawValue>: LosslessStringConvertible, Equatable, Hashable where RawValue: LosslessStringConvertible & Equatable & Hashable {
    public let value: RawValue

    public var description: String {
        value.description
    }

    public init?(_ stringValue: String) {
        guard let value = RawValue(stringValue) else { return nil }
        self.value = value
    }

    public init(value: RawValue) {
        self.value = value
    }
}

extension Identifier: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let value = RawValue(stringValue) {
            self.value = value
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Coudn't be parsed as \(type(of: RawValue.self))")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.description)
    }
}
