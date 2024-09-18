//
//  ExtensionTests.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 19.04.21.
//

@testable import PharmaDatabase
import XCTest

class StringHTMLTests: XCTestCase {

    func testThat_MatchingStrings_AreAmendedWihBoldTags() {
        let words = ["tribune", "perspire", "procure", "divulge", "twosome", "palazzi", "tilth", "tanager", "waddle", "egotist", "fatuity", "today", "debark", "pabulum", "roach", "korean", "carton", "plaster", "corundum", "keynote", "sterile", "uncle", "meow", "tumbler", "auto", "fugitive", "madam", "gaur", "sinuous", "yoyo", "", "", UUID().uuidString, String(Int.fixture()), String.fixture()] // -> contains empty strings to make sure "bolding" does not choke at edge cases

        for _ in 0...Int.random(in: 200...400) {
            guard let prefix = words.randomElement(),
                  let bold = words.randomElement(),
                  let suffix = words.randomElement()
            else {
                return XCTFail("Unexpected nil value")
            }

            let string = "\(prefix)\(bold)\(suffix)"
            let result = string.bolded(matching: bold)

            let range = result.range(of: "<b>\(bold)</b>")
            if bold.isEmpty {
                XCTAssertNil(range)
            } else {
                XCTAssertNotNil(range)
            }
        }
    }

    func testThat_NonMatchingStrings_AreNotAmendedWihBoldTags() {
        let words = ["truss", "jain", "macerate", "filling", "cheep", "monogram", "milan", "atlantic", "salivate", "bat", "absentee", "haitian", "rigour", "piquant", "ghanian", "infold", "goose", "posey", "outbid", "airline"]

        let matchingTerms = ["auxin", "describe", "scrubby", "auburn", "prostate", "spite", "holt", "shrunken", "tritium", "navajo", "allegory", "argument", "costly", "deviancy", "burglar", "rapier", "intermit", "doodle", "moly", "goof"]

        for _ in 0...Int.random(in: 200...400) {
            guard let prefix = words.randomElement(),
                  let middle = words.randomElement(),
                  let suffix = words.randomElement(),
                  let term = matchingTerms.randomElement()
            else {
                return XCTFail("Unexpected nil value")
            }

            let string = "\(prefix)\(middle)\(suffix)"
            let result = string.bolded(matching: term)

            XCTAssertNil(result.range(of: "<b>"))
            XCTAssertNil(result.range(of: "</b>"))
        }
    }
}
