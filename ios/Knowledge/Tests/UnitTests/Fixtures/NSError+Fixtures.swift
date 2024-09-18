//
//  NSError+Fixtures.swift
//  KnowledgeTests
//
//  Created by Cornelius Horstmann on 29.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import FixtureFactory
import Foundation

extension NSError: Fixture {
    public static func fixture() -> Self {
        NSError.fixture(domain: .fixture(), code: .fixture(), userInfo: nil) as! Self
    }

    public static func fixture(domain: String = .fixture(), code: Int = .fixture(), userInfo: [String: Any]? = nil) -> Self {
        NSError(domain: domain, code: code, userInfo: userInfo) as! Self
    }
}
