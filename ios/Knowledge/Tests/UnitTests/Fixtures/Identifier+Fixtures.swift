//
//  Identifier+Fixtures.swift
//  KnowledgeTests
//
//  Created by CSH on 22.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import FixtureFactory
import Foundation
import Domain

extension Identifier: Fixture where RawValue: Fixture {
    public static func fixture() -> Identifier {
        fixture(value: .fixture())
    }
    public static func fixture(value: RawValue = .fixture()) -> Identifier {
        Identifier<Identified, RawValue>(value: value)
    }
}
