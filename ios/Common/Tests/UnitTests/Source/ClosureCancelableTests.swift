//
//  ClosureCancelableTests.swift
//  CommonTests
//
//  Created by Cornelius Horstmann on 04.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import XCTest
import Common

class ClosureCancelableTests: XCTestCase {

    func testThatTheCancelClosureIsCalledWhenCancelIsCalled() {
        let cancelClosureWasCalledExpectation = expectation(description: "cancel closure was called")

        let cancelable = ClosureCancelable {
            cancelClosureWasCalledExpectation.fulfill()
        }

        cancelable.cancel()

        waitForExpectations(timeout: 0.1)
    }

    func testThatTheCancelClosureIsCalledWhenTheCancelableIsDeallocated() {
        let cancelClosureWasCalledExpectation = expectation(description: "cancel closure was called")

        var cancelable: ClosureCancelable? = ClosureCancelable {
            cancelClosureWasCalledExpectation.fulfill()
        }

        if cancelable != nil { cancelable = nil }

        waitForExpectations(timeout: 0.1)
    }

}
