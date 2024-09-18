//
//  OneTimeToken.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 07.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

public struct OneTimeToken: Decodable {
    public let token: String

    // sourcery: fixture:
    public init(token: String) {
        self.token = token
    }
}
