//
//  APIAgentTests.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 16.04.21.
//

import GRDB
import Domain
@testable import PharmaDatabase
import XCTest

class SearchTests: XCTestCase {

    // MARK: - Selecting results

    func testThat_SearchingForMatchesInColumn_Name_ReturnsExpectedNumberOfResults() throws {

        let range = 0..<Int.random(in: 200...800)
        let drugs = Array(range).map { _ in PharmaDatabase.Row.Drug.fixture() }
        let agents = Array(range).map { _ in PharmaDatabase.Row.AmbossSubstance.fixture(based_on_drug_id: drugs.randomElement()!.id, published: true) }

        // Insert agents with a specific name, that will be searched for ...
        let fragment = UUID().uuidString // <- Random string is not unique enough
        let agentsToMatch = Array(0..<Int.random(in: 30...90)).map { _ in
            PharmaDatabase.Row.AmbossSubstance.fixture(name: "\(fragment)\(String.fixture())", based_on_drug_id: drugs.randomElement()!.id, published: true)
        }

        // Insert a couple more agents, that are not "published" in order to make sure those are ignored
        let agentsToIgnore = Array(0..<Int.random(in: 30...90)).map { _ in
            PharmaDatabase.Row.AmbossSubstance.fixture(name: "\(fragment)\(String.fixture())", based_on_drug_id: drugs.randomElement()!.id, published: false)
        }
        XCTAssert(agentsToIgnore.count > 0)

        var rows = [PersistableRecord]()
        rows.append(contentsOf: agents)
        rows.append(contentsOf: agentsToMatch)
        rows.append(contentsOf: agentsToIgnore)
        rows.append(contentsOf: drugs)
        rows.shuffle() // <- to make it a bit more realistic

        let queue = try PharmaDatabase.fixture(insert: rows)
        let database = try PharmaDatabase(queue: queue)

        let foundPharmaItems = try database.items(for: fragment)
        XCTAssertEqual(foundPharmaItems.count, agentsToMatch.count)
    }

    // MARK: - Result formatting

    func testThat_TheSearchTerm_IsBoldIn_ResultItem_Title() throws {

        let version = PharmaDatabase.Row.Version.fixture(major: PharmaDatabase.supportedMajorSchemaVersion, minor: PharmaDatabase.supportedMinorSchemaVersion)
        let range = 0..<Int.random(in: 200...800)
        let drugs = Array(range).map { _ in PharmaDatabase.Row.Drug.fixture() }
        let agents = Array(range).map { _ in PharmaDatabase.Row.AmbossSubstance.fixture(name: NSUUID().uuidString, based_on_drug_id: drugs.randomElement()!.id, published: true) }

        var rows = [PersistableRecord]()
        rows.append(version)
        rows.append(contentsOf: agents)
        rows.append(contentsOf: drugs)

        let queue = try PharmaDatabase.fixture(insert: rows)
        let database = try PharmaDatabase(queue: queue)

        for agent in agents {
            guard let name = agent.name else { return XCTFail("agent.name must not be nil") }
            let item = try XCTUnwrap(try database.items(for: name).first)
            XCTAssertTrue(item.title.contains("<b>"))
            XCTAssertTrue(item.title.contains("</b>"))
        }
    }

    func testThat_TheSearchTerm_IsBoldIn_ResultItem_Details() throws {

        let pharmaCards: [(uuid: String, ambossSubstance: PharmaDatabase.Row.AmbossSubstance, drug: PharmaDatabase.Row.Drug)] = Array(0..<Int.random(in: 200...800)).map { _ in
            let uuid = NSUUID().uuidString
            let drugId = NSUUID().uuidString
            return (uuid,
                    PharmaDatabase.Row.AmbossSubstance.fixture(name: uuid, based_on_drug_id: drugId, published: true),
                    PharmaDatabase.Row.Drug.fixture(id: drugId, atc_label: uuid)
            )
        }

        var toInsert: [PersistableRecord] = pharmaCards.map { _, agent, _ in agent }
        toInsert.append(contentsOf: pharmaCards.map { _, _, drug in drug })
        let queue = try PharmaDatabase.fixture(insert: toInsert)
        let database = try PharmaDatabase(queue: queue)

        for (uuid, ambossSubstance, _) in pharmaCards {
            guard let name = ambossSubstance.name else { return XCTFail("ambossSubstance.name must not be nil") }
            let item = try XCTUnwrap(try database.items(for: name).first)
            let details = String(describing: item.details)
            XCTAssertTrue(details.contains("<b>\(uuid)</b>"), "Item details do not contain bold tag: \(item)")
        }
    }

    func testThat_MatchesAreOrderedBy_ResemblanceToSearchTerm() throws {

        let version = PharmaDatabase.Row.Version.fixture(major: PharmaDatabase.supportedMajorSchemaVersion, minor: PharmaDatabase.supportedMinorSchemaVersion)

        let names = ["Hydrochlorothiazid | Ramipril", "Acetylsalicylsäure | Atorvastatin | Ramipril", "Amlodipin | Hydrochlorothiazid | Ramipril", "Felodipin | Ramipril", "Amlodipin | Ramipril", "Ramipril", "Piretanid | Ramipril"]
        let drugs = names.map { _ in PharmaDatabase.Row.Drug.fixture() }
        let agents = names.map { PharmaDatabase.Row.AmbossSubstance.fixture(name: $0, based_on_drug_id: drugs.randomElement()!.id, published: true) }

        var rows = [PersistableRecord]()
        rows.append(version)
        rows.append(contentsOf: agents)
        rows.append(contentsOf: drugs)

        let queue = try PharmaDatabase.fixture(insert: rows)
        let database = try PharmaDatabase(queue: queue)

        let items = try database.items(for: "Ramipril")
        let titles = items.map { $0.title }

        XCTAssertEqual(titles, [
            "<b>Ramipril</b>",
            "Amlodipin | <b>Ramipril</b>",
            "Felodipin | <b>Ramipril</b>",
            "Piretanid | <b>Ramipril</b>",
            "Hydrochlorothiazid | <b>Ramipril</b>",
            "Amlodipin | Hydrochlorothiazid | <b>Ramipril</b>",
            "Acetylsalicylsäure | Atorvastatin | <b>Ramipril</b>"
        ])
    }
}
