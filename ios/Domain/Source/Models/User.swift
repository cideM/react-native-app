//
//  User.swift
//  Networking
//
//  Created by CSH on 13.05.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public typealias UserIdentifier = Identifier<User, String>

public struct User: Equatable {
    public let identifier: UserIdentifier
    public let firstName: String?
    public let lastName: String?
    public let email: String?

    // sourcery: fixture:
    public init(userIdentifier: UserIdentifier, firstName: String?, lastName: String?, email: String?) {
        self.identifier = userIdentifier
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}

extension User: Codable {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
    }
}
