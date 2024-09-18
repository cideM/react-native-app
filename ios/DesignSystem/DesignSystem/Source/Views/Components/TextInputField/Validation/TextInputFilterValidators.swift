//
//  TextInputFilterValidators.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 24.11.23.
//

import Foundation

// MARK: - Validator
public class NotEmptyValidator: StringValidation {
    public init() {}
    public func validate(input: String?) -> Bool {
        (input ?? "").isEmpty == false
    }
}
