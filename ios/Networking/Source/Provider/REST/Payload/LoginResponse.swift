//
//  LoginResponse.swift
//  Interfaces
//
//  Created by Aamir Suhial Mir on 24.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

struct LoginResponse {
    let authentication: Authentication

    struct Authentication: Equatable {
        let token: String
        let user: User

        // sourcery: fixture:
        init(token: String, user: User) {
            self.token = token
            self.user = user
        }

        // swiftlint:disable:next nesting
        struct User: Equatable {
            let userId: String
            let firstName: String?
            let lastName: String?
            let email: String?

            init(userId: String, firstName: String?, lastName: String?, email: String?) {
                self.userId = userId
                self.firstName = firstName
                self.lastName = lastName
                self.email = email
            }
        }
    }
}

extension LoginResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case authentication
    }
}

extension LoginResponse.Authentication: Decodable {
    enum CodingKeys: String, CodingKey {
        case token
        case user
    }
}

extension LoginResponse.Authentication.User: Decodable {
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
    }
}
