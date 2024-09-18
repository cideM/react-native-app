//
//  AuthorizationRepository.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 12.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

/// @mockable
protocol AuthorizationRepositoryType: AnyObject {
    var deviceId: String { get }
    var authorization: Authorization? { get set }
    var accountWasDeleted: Bool? { get set }
}

final class AuthorizationRepository {
    private let storage: Storage
    var accountWasDeleted: Bool?

    init(storage: Storage) {
        self.storage = storage
    }
}

extension AuthorizationRepository: AuthorizationRepositoryType {
    var deviceId: String {
        if let deviceId: String = storage.get(for: .deviceIdentifier) {
            return deviceId
        }
        let deviceId = UUID().uuidString
        storage.store(deviceId, for: .deviceIdentifier)
        return deviceId
    }

    var authorization: Authorization? {
        get {
            storage.get(for: .authorization)
        }
        set {
            storage.store(newValue, for: .authorization)
        }
    }
}
