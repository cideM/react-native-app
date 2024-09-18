//
//  AccessError.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 26.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

// sourcery: fixture:
public enum AccessError: Equatable, Error {
    case offlineAccessExpired
    case accessRequired
    case accessExpired
    case accessConsumed
    case campusLicenseUserAccessExpired
    case unknown(String)

    public init(string: String) {
        switch string {
        case "offlineAccessExpired": self = .offlineAccessExpired
        case "access_required": self = .accessRequired
        case "access_consumed": self = .accessConsumed
        case "access_expired": self = .accessExpired
        case "campus_license_user_access_expired": self = .campusLicenseUserAccessExpired
        case let string: self = .unknown(string)
        }
    }

    public var string: String {
        switch self {
        case .offlineAccessExpired: return "offlineAccessExpired"
        case .accessRequired: return "access_required"
        case .accessConsumed: return "access_consumed"
        case .accessExpired: return "access_expired"
        case .campusLicenseUserAccessExpired: return "campus_license_user_access_expired"
        case .unknown(let string): return string
        }
    }
}

extension AccessError: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = .init(string: string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
}
