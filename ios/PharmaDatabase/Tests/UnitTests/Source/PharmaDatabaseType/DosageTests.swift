//
//  DosageTests.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 11.10.22.
//

import GRDB
import Domain
@testable import PharmaDatabase
import XCTest

class DosageTests: XCTestCase {

    func testThat_ExpectedDosagesAreReturned_ForDosageIdentifiers() throws {

        let count = Int.random(in: 100...400)

        // Dosage contains "substanceId" and "substanceName" and fetching fails
        // if these are not available in the db (substance == agent) ...
        var agentRows = [PersistableRecord]()
        for index in 0..<count {
            agentRows.append(PharmaDatabase.Row.AmbossSubstance.fixture(id: "\(index)"))
        }

        var dosageRows = [PersistableRecord]()
        for (index, row) in agentRows.enumerated() {
            let agent = try XCTUnwrap(row as? PharmaDatabase.Row.AmbossSubstance)
            let agentId = try XCTUnwrap(agent.id)
            // Doing the "id" here manually cause ".fixture" is not unique enough ...
            dosageRows.append(PharmaDatabase.Row.Dosage.fixture(id: "\(index)", as_link_as_id: agentId))
        }

        let rows = agentRows + dosageRows
        XCTAssertFalse(rows.isEmpty)

        let queue = try PharmaDatabase.fixture(insert: rows)
        let database = try PharmaDatabase(queue: queue)

        for fixture in dosageRows {
            guard let dosage = fixture as? PharmaDatabase.Row.Dosage else {
                XCTFail("Row should be of tpye dosage but its not.")
                return
            }
            let id = DosageIdentifier(value: String(describing: dosage.id))
            let dosageFromDB = try database.dosage(for: id)

            XCTAssertEqual(String(describing: dosage.id), dosageFromDB.id.value)
            XCTAssertEqual(dosage.html, dosageFromDB.html)
        }
    }
}
