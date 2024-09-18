//
//  AgentTests.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 23.04.21.
//

import GRDB
import Domain
@testable import PharmaDatabase
import XCTest

class AgentQueryTests: XCTestCase {

    // MARK: - Query: Succcess cases

    func testThat_AnAgentIsReturned_ForAMatchingAgentID() throws {

        let version = PharmaDatabase.Row.Version.fixture(major: PharmaDatabase.supportedMajorSchemaVersion, minor: PharmaDatabase.supportedMinorSchemaVersion)

        let dosageForms = "[\"\(String.fixture())\", \"\(String.fixture())\", \"\(String.fixture())\", \"\(String.fixture())\"]"

        let drug = PharmaDatabase.Row.Drug.fixture()
        let ambossSubstance = PharmaDatabase.Row.AmbossSubstance.fixture(based_on_drug_id: drug.id, dosage_forms: dosageForms)

        // Insert a section and a mapping table here as well to make sure all code pathes are triggered
        let section = PharmaDatabase.Row.Section.fixture(content: Data.singleSectionContentJSONData.deflate())
        let drugSection = PharmaDatabase.Row.DrugSection.fixture(drug_id: drug.id, section_id: String(section.id), position: .fixture())

        let rows: [PersistableRecord] = [version, section, ambossSubstance, drug, drugSection]
        let queue = try PharmaDatabase.fixture(insert: rows)
        let database = try PharmaDatabase(queue: queue)

        let identifier = SubstanceIdentifier(value: ambossSubstance.id)
        let result = try database.substance(for: identifier)
        XCTAssertEqual(result.name, ambossSubstance.name) // -> More detailed tests in Agent.Tests.swift
    }

    func testThat_AnErrorIsThrown_WhenSearchingFor_ANonExistingAmbossSubstanceID() throws {
        let dosageForms = "[\"\(String.fixture())\", \"\(String.fixture())\", \"\(String.fixture())\", \"\(String.fixture())\"]"
        let row = PharmaDatabase.Row.AmbossSubstance.fixture(dosage_forms: dosageForms)

        let queue = try PharmaDatabase.fixture(insert: [
            PharmaDatabase.Row.Version.fixture(major: PharmaDatabase.supportedMajorSchemaVersion, minor: PharmaDatabase.supportedMinorSchemaVersion),
            row
        ])
        let database = try PharmaDatabase(queue: queue)

        let identifier = SubstanceIdentifier(value: String.fixture())

        XCTAssertThrowsError(try database.substance(for: identifier), "Should throw error") {
            guard let error = $0 as? PharmaDatabase.FetchError else {
                return XCTFail("Error is of unexpected type. Should be PharmaDatabase.FetchError but is: \($0)")
            }
            switch error {
            case .unexpectedNilValue(let table, let column, let id):
                XCTAssertEqual(table, "amboss_substance")
                XCTAssertEqual(column, "id")
                XCTAssertEqual(id, identifier.value)
            default:
                return XCTFail("Error is of unexpected type. Should be PharmaDatabase.FetchError but is: \($0)")
            }
        }
    }
}
