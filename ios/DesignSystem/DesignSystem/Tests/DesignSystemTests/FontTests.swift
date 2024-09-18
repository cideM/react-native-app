//
//  FontTests.swift
//  UnitTests
//
//  Created by Manaf Alabd Alrahim on 29.08.23.
//

import XCTest
@testable import DesignSystem

final class FontTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        DesignSystem.initialize()
    }
    override class func tearDown() {
        super.tearDown()
        DesignSystem.deinitialize()
    }
    
    func testFontInitialization() throws {
        
        XCTAssertNotNil(UIFont.font(family: .lato, weight: .regular, size: .textXS))
        XCTAssertNotNil(UIFont.font(family: .lato, weight: .bold, size: .textXS))
        XCTAssertNotNil(UIFont.font(family: .lato, weight: .black, size: .textXS))
        XCTAssertNotNil(UIFont.font(family: .lato, weight: .regular, size: .textXS)?.italic())
        XCTAssertNotNil(UIFont.font(family: .lato, weight: .bold, size: .textXS)?.italic())
        XCTAssertNotNil(UIFont.font(family: .lato, weight: .black, size: .textXS)?.italic())
    }
}
