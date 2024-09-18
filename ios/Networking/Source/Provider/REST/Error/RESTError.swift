//
//  RESTError.swift
//  Networking
//
//  Created by Vedran Burojevic on 01/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

enum RESTError: Error {
    case invalidAuthorization

    init?(_ data: Data?) {
        guard let data = data, let dataString = String(data: data, encoding: .utf8) else { return nil }

        if dataString.contains("INVALID_CREDENTIALS") {
            self = .invalidAuthorization
        } else {
            return nil
        }
    }
}
