//
//  Array+SubarraysTests.swift
//  RichTextRendererTests
//
//  Created by Mohamed Abdul Hameed on 02.02.21.
//

import XCTest
@testable import RichTextRenderer

class ArraySubarraysTests: XCTestCase {
    func testThatItReturnsEmptyArrayWhenTryingToSplitAnEmptyArray() {
        let array: [String] = []
        let indices = [0]
        
        let result = array.subarrays(indices: indices)
        
        XCTAssertEqual(result, [[]])
    }
    
    func testThatItReturnsSameArrayIfTheIndicesArrayIsEmpty() {
        let array = ["1", "2", "3"]
        let indices: [Int] = []
        
        let result = array.subarrays(indices: indices)
        
        XCTAssertEqual(result, [["1", "2", "3"]])
    }
    
    func testThatItWorksForOneElementArray() {
        let array = ["0"]
        let indices = [0]
        
        let result = array.subarrays(indices: indices)
        
        XCTAssertEqual(result, [["0"]])
    }
    
    func testThatItWorksForMultipleIndices() {
        let array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        let indices = [3, 6]
        
        let result = array.subarrays(indices: indices)
        
        XCTAssertEqual(result, [["0", "1", "2"], ["3"], ["4", "5"], ["6"], ["7", "8", "9", "10"]])
    }
    
    func testThatItWorksForAnArrayWithAnIndexInTheBeginning() {
        let array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        let indices = [0]
        
        let result = array.subarrays(indices: indices)
        
        XCTAssertEqual(result, [["0"], ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]])
    }
    
    func testThatItWorksForAnArrayWithAnIndexInTheEnd() {
        let array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        let indices = [10]
        
        let result = array.subarrays(indices: indices)
        
        XCTAssertEqual(result, [["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], ["10"]])
    }
    
    func testThatItWorksForAnArrayWithAnIndexInTheEndAndIndexInTheBeginning() {
        let array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        let indices = [0, 10]
        
        let result = array.subarrays(indices: indices)
        
        XCTAssertEqual(result, [["0"], ["1", "2", "3", "4", "5", "6", "7", "8", "9"], ["10"]])
    }
}
