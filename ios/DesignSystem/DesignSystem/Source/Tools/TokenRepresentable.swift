//
//  TokenRepresentable.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.08.23.
//

import Foundation

public protocol TokenRepresentable: RawRepresentable { }

extension TokenRepresentable {
    public init?(rawValue: RawValue) {
        nil
    }
}
