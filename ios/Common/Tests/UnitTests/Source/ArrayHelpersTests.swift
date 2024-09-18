//
//  ArrayHelpersTests.swift
//  CommonTests
//
//  Created by Cornelius Horstmann on 04.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import XCTest
import Common

class ArrayHelpersTests: XCTestCase {

    func testThatChunkedWorksIfTheArrayIsSmallerThanTheChunkSize() {
        let array = [1, 2]
        let chunked = array.chunked(into: 3)
        XCTAssertEqual(chunked, [[1, 2]])
    }

    func testThatChunkedWorksIfTheNumberOfItemsIsDividableByTheChunkSize() {
        let array = [1, 2, 3, 4]
        let chunked = array.chunked(into: 2)
        XCTAssertEqual(chunked, [[1, 2], [3, 4]])
    }

    func testThatChunkedWorksIfTheNumberOfItemsIsNotDividableByTheChunkSize() {
        let array = [1, 2, 3, 4]
        let chunked = array.chunked(into: 3)
        XCTAssertEqual(chunked, [[1, 2, 3], [4]])
    }

    func testThatArrayWithElementsSeparatedInsertsTheSeparatorBetweenAllElements() {
        let array = [1, 2, 3]
        let separated = array.arrayWithElementsSeparated(by: 0)
        XCTAssertEqual(separated, [1, 0, 2, 0, 3])
    }

}
