//
//  Access.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 26.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

// sourcery: fixture:
public enum Access: Codable, Equatable {
    case granted(_ expiresAt: Date)
    case denied(AccessError)

    private enum CodingKeys: CodingKey {
        case granted
        case denied
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let date = try? container.decode(Date.self, forKey: .granted) {
            self = .granted(date)
        } else if let accessError = try? container.decode(AccessError.self, forKey: .denied) {
            self = .denied(accessError)
        } else {
            self = .denied(.unknown("Unable to decode Access"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .granted(let date):
            try container.encode(date, forKey: .granted)
        case .denied(let accessError):
            try container.encode(accessError, forKey: .denied)
        }
    }

    /// Returns whethere there is access on a specific date or not.
    /// This method returns `.success` with an empty tuple in case there is access and in case there is no access it returns `.failure` with a specific error that describes the reason.
    /// - Parameter date: The date to check the access against.
    public func getAccess(at date: Date) -> Result<Void, AccessError> {
        switch self {
        case .denied(let error): return .failure(error)
        case .granted(let expiration):
            if expiration < date {
                return .failure(.offlineAccessExpired)
            } else {
                return .success(())
            }
        }
    }
}
