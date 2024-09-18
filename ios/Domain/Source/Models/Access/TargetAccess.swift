//
//  TargetAccess.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 26.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct TargetAccess: Codable, Equatable {
    public let target: AccessTarget
    public let access: Access

    // sourcery: fixture:
    public init(target: AccessTarget, access: Access) {
        self.target = target
        self.access = access
    }
}
