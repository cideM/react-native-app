//
//  AmbossSubstanceTests.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 03.05.21.
//

import GRDB
import Domain
@testable import PharmaDatabase
import XCTest

class AmbossSubstanceTests: XCTestCase {

    // MARK: - Success cases

    func testThat_InitializingAnAmbossSubstance_WithValidData_ReturnsExpectedResult() throws {
        let dosages = (String.fixture(), String.fixture(), String.fixture(), String.fixture())
        let dosageForms = "[\"\(dosages.0)\", \"\(dosages.1)\", \"\(dosages.2)\", \"\(dosages.3)\"]"
        let row = PharmaDatabase.Row.AmbossSubstance.fixture(dosage_forms: dosageForms, published_at_ts: 0, published: true)

        let prescriptions = ("prescriptionOnly", "narcotic")
        let prescriptionsArray = "[\"\(prescriptions.0)\", \"\(prescriptions.1)\"]"
        let applicationForms = ("bronchial", "topical")
        let applicationFormsArray = "[\"\(applicationForms.0)\", \"\(applicationForms.1)\"]"

        let drug = PharmaDatabase.Row.Drug.fixture(application_forms: applicationFormsArray, prescriptions: prescriptionsArray, dosage_forms: dosageForms, published_at_ts: 0)

        let agent = try Substance(row: row, drugs: [drug], pocketCard: nil)

        XCTAssertEqual(agent.id.value, row.id)
        XCTAssertEqual(agent.name, row.name)

        XCTAssertEqual(agent.drugReferences.count, 1)
        XCTAssertEqual(String(describing: agent.drugReferences.first!.prescriptions[0]), prescriptions.0)
        XCTAssertEqual(String(describing: agent.drugReferences.first!.applicationForms[0]), applicationForms.0)
    }

    // MARK: - Failure cases

    func testThat_InitializingAnAmbossSubstance_WithAMissing_Name_ThrowsAnError() throws {
        let row = PharmaDatabase.Row.AmbossSubstance.fixture(name: nil)
        XCTAssertThrowsError(try Substance(row: row, drugs: [], pocketCard: nil), "Should throw error") {
            guard let error = $0 as? PharmaDatabase.FetchError else {
                return XCTFail("Unexpected error type. Should be PharmaDatabase.FetchError but is: \($0)")
            }
            switch error {
            case .unexpectedNilValue(let table, let column, let id):
                XCTAssertEqual(table, "amboss_substance")
                XCTAssertEqual(column, "name")
                XCTAssertEqual(id, row.id)
            default:
                XCTFail("Unexpected state. Should be .unexpectedNilValue but is: \(error)")
            }
        }
    }
}
