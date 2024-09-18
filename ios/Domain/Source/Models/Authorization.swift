//
//  Authorization.swift
//  Networking
//
//  Created by CSH on 13.05.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct Authorization: Equatable {
    public let token: String
    public let user: User

    // sourcery: fixture:
    public init(token: String, user: User) {
        self.token = token
        self.user = user
    }
}

extension Authorization: Codable {
    enum CodingKeys: String, CodingKey {
        case token
        case user
    }
}
