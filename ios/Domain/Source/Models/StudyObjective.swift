//
//  StudyObjective.swift
//  Interfaces
//
//  Created by CSH on 13.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct StudyObjective: Equatable, Codable {

    public let eid: String
    public let name: String
    public let superset: String?

    // sourcery: fixture:
    public init(eid: String, name: String, superset: String? = nil) {
        self.eid = eid
        self.name = name
        self.superset = superset
    }

}
