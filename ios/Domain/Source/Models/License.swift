//
//  License.swift
//  Networking
//
//  Created by CSH on 13.05.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct License: Decodable {
    public let title: String
    public let status: String

    public init(title: String, status: String) {
        self.title = title
        self.status = status
    }
}
