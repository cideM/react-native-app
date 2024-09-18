//
//  JSONFileInstantiatable+ZippyJSONDecoder.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 02.05.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
import ZippyJSON
import Foundation

public extension JSONFileInstantiatable where Self: Decodable {

    static func objectFromFile(_ url: URL) throws -> Self {
        #if targetEnvironment(simulator)
        let decoder = JSONDecoder()
        #else
        let decoder = ZippyJSONDecoder()
        #endif
        let fileData = try Data(contentsOf: url)
        return try decoder.decode(Self.self, from: fileData)
    }

    static func arrayFromFile(_ url: URL) throws -> [Self] {
        #if targetEnvironment(simulator)
        let decoder = JSONDecoder()
        #else
        let decoder = ZippyJSONDecoder()
        #endif
        let fileData = try Data(contentsOf: url)
        return try decoder.decode([Self].self, from: fileData)
    }
}
