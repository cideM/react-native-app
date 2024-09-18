//
//  PointableStackTests.swift
//  CommonTests
//
//  Created by CSH on 28.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

// swiftlint:disable force_unwrapping

import Common
import XCTest

class PointableStackTests: XCTestCase {

    func testThatCurrentItemIsNilForAnEmptyStack() {
        let stack = PointableStack<String>()

        XCTAssertNil(stack.currentItem)
    }

    func testThatCurrentItemReturnsTheLastAddedItem() {
        let stack = PointableStack<String>()
        stack.append("spec_1")

        let item = "spec_3"
        stack.append(item)

        XCTAssertEqual(stack.currentItem!, item)
    }

    func testThatThePointerIsDecreasableIfNotPointingToTheFirstItem() {
        let stack = PointableStack<String>()
        stack.append("spec_1")
        stack.append("spec_2")

        XCTAssertTrue(stack.isPointerDecreasable)
    }

    func testThatThePointerIsNotDecreasableIfPointingToTheFirstItem() {
        let stack = PointableStack<String>()
        stack.append("spec_1")
        stack.append("spec_2")

        stack.decreasePointer()

        XCTAssertFalse(stack.isPointerDecreasable)
    }

    func testThatThePointerIsIncreasableNotPointingToTheLastItem() {
        let stack = PointableStack<String>()
        stack.append("spec_1")
        stack.append("spec_2")

        stack.decreasePointer()
        XCTAssertTrue(stack.isPointerIncreasable)
    }

    func testThatThePointerIsNotIncreasableIfPointingToTheLastItem() {
        let stack = PointableStack<String>()
        stack.append("spec_1")
        stack.append("spec_2")

        XCTAssertFalse(stack.isPointerIncreasable)
    }

    func testThatCurrentItemUpdatesWhenDecreasingThePointer() {
        let stack = PointableStack<String>()
        stack.append("spec_1")
        stack.append("spec_2")

        stack.decreasePointer()

        XCTAssertEqual(stack.currentItem!, "spec_1")
    }

    func testThatCurrentItemUpdatesWhenIncreasingThePointer() {
        let stack = PointableStack<String>()
        stack.append("spec_1")
        stack.append("spec_2")

        stack.decreasePointer()
        stack.increasePointer()

        XCTAssertEqual(stack.currentItem!, "spec_2")
    }

    func testThatAppendingAnItemDropsAllItemsAfterTheCurrentOne() {
        let stack = PointableStack<String>()
        stack.append("spec_1")
        stack.append("spec_2")

        stack.decreasePointer()
        stack.append("spec_3")

        XCTAssertFalse(stack.isPointerIncreasable)
        XCTAssertEqual(stack.currentItem!, "spec_3")
        stack.decreasePointer()
        XCTAssertFalse(stack.isPointerDecreasable)
        XCTAssertEqual(stack.currentItem!, "spec_1")
    }

}
