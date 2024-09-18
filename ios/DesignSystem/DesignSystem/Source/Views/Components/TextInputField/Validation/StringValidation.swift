//
//  StringValidation.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 28.11.23.
//

import Foundation

// MARK: - TextInputFilterValidator Protocol
public protocol StringValidation {
    var errorMessage: String? { get }
    func validate(input: String?) -> Bool
}

public extension StringValidation {
    var errorMessage: String? { nil }
}
