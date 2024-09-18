//
//  UserDefaultsStorageTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 18.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class UserDefaultsStorageTests: XCTestCase {

    var storage: Storage!

    override func setUp() {
        storage = UserDefaultsStorage(.standard)
    }

    func testThatGettingABooleanValueFromUserDefaultsForANonExistingKeyReturnsNil() {
        let boolValue: Bool? = storage.get(for: "undefined_bool_key")
        XCTAssertNil(boolValue)
    }

    func testThatGettingAnIntegerValueFromUserDefaultsForANonExistingKeyReturnsNil() {
        let intValue: Int? = storage.get(for: "undefined_int_key")
        XCTAssertNil(intValue)
    }

    func testThatGettingAStringValueFromUserDefaultsForANonExistingKeyReturnsNil() {
        let strValue: String? = storage.get(for: "undefined_str_key")
        XCTAssertNil(strValue)
    }

    func testThatGettingADateValueFromUserDefaultsForANonExistingKeyReturnsNil() {
        let dateValue: Date? = storage.get(for: "undefined_date_key")
        XCTAssertNil(dateValue)
    }
}
