//
//  SuggestionsTests.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 20.04.21.
//

import GRDB
import Domain
@testable import PharmaDatabase
import XCTest

class SuggestionsTests: XCTestCase {

    func testThat_ExpectedSuggestionsAreReturned_ForSearchTerms() throws {

        var rows = [PersistableRecord]()
        let searchAndSuggestTerms: [(searchTerm: String, suggestTerm: String)] = Array(repeating: { (searchTerm: NSUUID().uuidString, suggestTerm: NSUUID().uuidString) }(), count: 100)
        let agents = searchAndSuggestTerms.map { searchTerm, suggestTerm in
            PharmaDatabase.Row.AmbossSubstance.fixture(search_terms: "[\"\(searchTerm)\"]", suggest_terms: "[\"\(suggestTerm)\"]", published: true)
        }
        rows.append(contentsOf: agents)

        let queue = try PharmaDatabase.fixture(insert: rows)
        let database = try PharmaDatabase(queue: queue)

        for (searchTerm, suggestTerm) in searchAndSuggestTerms {
            let suggestion = try XCTUnwrap(try database.suggestions(for: searchTerm, max: 25).first)
            XCTAssertEqual(suggestTerm, suggestion)
        }
    }

    func testThat_NoSuggestionsAreReturned_ForSubstancesThatAreNotPublished() throws {

        var rows = [PersistableRecord]()
        let searchAndSuggestTerms: [(searchTerm: String, suggestTerm: String)] = Array(repeating: { (searchTerm: NSUUID().uuidString, suggestTerm: NSUUID().uuidString) }(), count: 100)
        let agents = searchAndSuggestTerms.map { searchTerm, suggestTerm in
            PharmaDatabase.Row.AmbossSubstance.fixture(search_terms: "[\"\(searchTerm)\"]", suggest_terms: "[\"\(suggestTerm)\"]", published: false)
        }
        rows.append(contentsOf: agents)

        let queue = try PharmaDatabase.fixture(insert: rows)
        let database = try PharmaDatabase(queue: queue)

        for (searchTerm, _) in searchAndSuggestTerms {
            let suggestions = try XCTUnwrap(try database.suggestions(for: searchTerm, max: 25))
            XCTAssert(suggestions.isEmpty)
        }
    }
}
