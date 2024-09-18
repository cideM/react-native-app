//
//  LoginRequestInput.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 07.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation

struct LoginRequestInput {
    let credential: Credential

    init(email: String, password: String) {
        self.credential = Credential(email: email, password: password)
    }

    struct Credential {
        let email: String
        let password: String
    }
}

extension LoginRequestInput: Encodable { }
extension LoginRequestInput.Credential: Encodable { }
