//
//  LoginError.swift
//  Networking
//
//  Created by Aamir Suhial Mir on 25.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

struct LoginError {
    let error: ServerError
}

struct ServerError: Codable {
    let message: String
}

extension LoginError: Codable {
    enum CodingKeys: String, CodingKey {
        case error = "errors"
    }
}
