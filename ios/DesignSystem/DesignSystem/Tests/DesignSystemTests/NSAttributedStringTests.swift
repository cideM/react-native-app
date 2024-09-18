//
//  NSAttributedStringTests.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 22.11.23.
//

import XCTest
@testable import DesignSystem

final class NSAttributedStringTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        DesignSystem.initialize()
    }

    override class func tearDown() {
        super.tearDown()
        DesignSystem.deinitialize()
    }

    func testNonEmptyAttributedStringCreation() throws {
        
        let decorations: [TextDecoration] = [
            .color(.textAccent),
            .italic,
            .underline(.textAccent),
            .alignment(.right)]

        for style in TextStyle.allCases {
            let _ = NSAttributedString.attributedString(with: "Test",
                                                        style: style,
                                                        decorations: decorations)
        }
    }

    func testEmptyAttributedStringCreation() throws {
        
        let decorations: [TextDecoration] = [
            .color(.textAccent),
            .italic,
            .underline(.textAccent),
            .alignment(.right)]

        for style in TextStyle.allCases {
            let _ = NSAttributedString.attributedString(with: "",
                                                        style: style,
                                                        decorations: decorations)
        }
    }
}
