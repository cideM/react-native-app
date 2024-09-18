//
//  KillSwitchDeprecationStatus.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 24.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

enum KillSwitchDeprecationStatus: Equatable {
    case deprecated(URL)
    case notDeprecated
}

extension KillSwitchDeprecationStatus: Codable {
    private enum CodingKeys: CodingKey {
        case deprecated, notDeprecated
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch container.allKeys.first {
        case .deprecated:
            let url = try container.decode(URL.self, forKey: .deprecated)
            self = .deprecated(url)
        case .notDeprecated:
            self = .notDeprecated
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unabled to decode enum."))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .deprecated(let url):
            try container.encode(url, forKey: .deprecated)
        case .notDeprecated:
            try container.encode(true, forKey: .notDeprecated)
        }
    }
}
