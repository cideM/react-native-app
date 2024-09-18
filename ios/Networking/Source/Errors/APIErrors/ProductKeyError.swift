//
//  ApplyAccessCodeError.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 20.12.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct ProductKeyError: Error {
    public let message: String
    public let errorType: ErrorType

    public enum ErrorType {
        case keyNotValid
        case alreadySubscribed
        case unknown
    }
}
