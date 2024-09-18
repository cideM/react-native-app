//
//  DrugTests.swift
//  PharmaDatabaseTests
//
//  Created by Silvio Bulla on 06.05.21.
//

import GRDB
import Domain
@testable import PharmaDatabase
import XCTest

class DrugReferenceTests: XCTestCase {

    func testThat_InitializingADrug_WithValidData_ReturnsExpectedResult() throws {
        let dosages = (String.fixture(), String.fixture(), String.fixture(), String.fixture())
        let dosageForms = "[\"\(dosages.0)\", \"\(dosages.1)\", \"\(dosages.2)\", \"\(dosages.3)\"]"
        let prescriptions = ("prescriptionOnly", "narcotic")
        let prescriptionsArray = "[\"\(prescriptions.0)\", \"\(prescriptions.1)\"]"
        let applicationForms = ("bronchial", "topical")
        let applicationFormsArray = "[\"\(applicationForms.0)\", \"\(applicationForms.1)\"]"
        let row = PharmaDatabase.Row.Drug.fixture(application_forms: applicationFormsArray, prescriptions: prescriptionsArray, dosage_forms: dosageForms)

        let drug = try DrugReference(row: row)

        XCTAssertEqual(drug.id.value, row.id)
        XCTAssertEqual(drug.name, row.name)
        XCTAssertEqual(drug.vendor, row.vendor)
        XCTAssertEqual(String(describing: drug.prescriptions[0]), prescriptions.0)
        XCTAssertEqual(String(describing: drug.prescriptions[1]), prescriptions.1)
        XCTAssertEqual(String(describing: drug.applicationForms[0]), applicationForms.0)
        XCTAssertEqual(String(describing: drug.applicationForms[1]), applicationForms.1)
    }

    func testThat_InitializingADrug_WithAMissing_Name_ThrowsAnError() {
        let row = PharmaDatabase.Row.Drug.fixture(name: nil)
        XCTAssertThrowsError(try DrugReference(row: row), "Should throw error") {
            guard let error = $0 as? PharmaDatabase.FetchError else {
                return XCTFail("Unexpected error type. Should be PharmaDatabase.FetchError but is: \($0)")
            }
            switch error {
            case .unexpectedNilValue(let table, let column, let id):
                XCTAssertEqual(table, "drug")
                XCTAssertEqual(column, "name")
                XCTAssertEqual(id, row.id)
            default:
                XCTFail("Unexpected state. Should be .unexpectedNilValue but is: \(error)")
            }
        }
    }

    func testThat_InitializingADrug_WithAMissing_atcLabel_ThrowsAnError() {
        let row = PharmaDatabase.Row.Drug.fixture(atc_label: nil)
        XCTAssertThrowsError(try DrugReference(row: row), "Should throw error") {
            guard let error = $0 as? PharmaDatabase.FetchError else {
                return XCTFail("Unexpected error type. Should be PharmaDatabase.FetchError but is: \($0)")
            }
            switch error {
            case .unexpectedNilValue(let table, let column, let id):
                XCTAssertEqual(table, "drug")
                XCTAssertEqual(column, "atc_label")
                XCTAssertEqual(id, row.id)
            default:
                XCTFail("Unexpected state. Should be .unexpectedNilValue but is: \(error)")
            }
        }
    }

    func testThat_InitializingADrug_WithMissing_Prescriptions_ThrowsAnError() {
        let dosages = (String.fixture(), String.fixture(), String.fixture(), String.fixture())
        let dosageForms = "[\"\(dosages.0)\", \"\(dosages.1)\", \"\(dosages.2)\", \"\(dosages.3)\"]"
        let applicationForms = ("bronchial", "topical")
        let applicationFormsArray = "[\"\(applicationForms.0)\", \"\(applicationForms.1)\"]"
        let row = PharmaDatabase.Row.Drug.fixture(application_forms: applicationFormsArray, prescriptions: nil, dosage_forms: dosageForms)
        XCTAssertThrowsError(try DrugReference(row: row), "Should throw error") {
            guard let error = $0 as? PharmaDatabase.FetchError else {
                return XCTFail("Unexpected error type. Should be PharmaDatabase.FetchError but is: \($0)")
            }
            switch error {
            case .unexpectedNilValue(let table, let column, let id):
                XCTAssertEqual(table, "drug")
                XCTAssertEqual(column, "prescriptions")
                XCTAssertEqual(id, row.id)
            default:
                XCTFail("Unexpected state. Should be .unexpectedNilValue but is: \(error)")
            }
        }
    }

    func testThat_InitializingADrug_WithUnsupported_PrescriptionType_ThrowsAnError() throws {
        let dosages = (String.fixture(), String.fixture(), String.fixture(), String.fixture())
        let dosageForms = "[\"\(dosages.0)\", \"\(dosages.1)\", \"\(dosages.2)\", \"\(dosages.3)\"]"
        let prescriptions = ("prescriptionOnly", "not_a_valid_prescription")
        let prescriptionsArray = "[\"\(prescriptions.0)\", \"\(prescriptions.1)\"]"
        let applicationForms = ("bronchial", "topical")
        let applicationFormsArray = "[\"\(applicationForms.0)\", \"\(applicationForms.1)\"]"

        let row = PharmaDatabase.Row.Drug.fixture(application_forms: applicationFormsArray, prescriptions: prescriptionsArray, dosage_forms: dosageForms)

        XCTAssertThrowsError(try DrugReference(row: row), "Should throw error: Invalid json") {
            guard let error = $0 as? PharmaDatabase.FetchError else {
                return XCTFail("Unexpected error type. Should be PharmaDatabase.FetchError but is: \($0)")
            }
            switch error {
            case .unexpectedJSONValue(let table, let column, let id, let jsonKey, let unexpectedValue):
                XCTAssertEqual(table, "drug")
                XCTAssertEqual(column, "prescriptions")
                XCTAssertEqual(id, row.id)
                XCTAssertEqual(jsonKey, "prescriptions")
                XCTAssertEqual(unexpectedValue, "not_a_valid_prescription")
            default:
                XCTFail("Unexpected state. Should be .dataCorrupted but is: \(error)")
            }
        }
    }

    func testThat_InitializingADrug_WithUnsupported_application_form_ThrowsAnError() throws {
        let dosages = (String.fixture(), String.fixture(), String.fixture(), String.fixture())
        let dosageForms = "[\"\(dosages.0)\", \"\(dosages.1)\", \"\(dosages.2)\", \"\(dosages.3)\"]"
        let prescriptions = ("prescriptionOnly", "narcotic")
        let prescriptionsArray = "[\"\(prescriptions.0)\", \"\(prescriptions.1)\"]"
        let applicationForms = ("bronchial", "not_a_valid_application_form")
        let applicationFormsArray = "[\"\(applicationForms.0)\", \"\(applicationForms.1)\"]"

        let row = PharmaDatabase.Row.Drug.fixture(application_forms: applicationFormsArray, prescriptions: prescriptionsArray, dosage_forms: dosageForms)

        XCTAssertThrowsError(try DrugReference(row: row), "Should throw error: Invalid json") {
            guard let error = $0 as? PharmaDatabase.FetchError else {
                return XCTFail("Unexpected error type. Should be PharmaDatabase.FetchError but is: \($0)")
            }
            switch error {
            case .unexpectedJSONValue(let table, let column, let id, let jsonKey, let unexpectedValue):
                XCTAssertEqual(table, "drug")
                XCTAssertEqual(column, "application_forms")
                XCTAssertEqual(id, row.id)
                XCTAssertEqual(jsonKey, "application_forms")
                XCTAssertEqual(unexpectedValue, "not_a_valid_application_form")
            default:
                XCTFail("Unexpected state. Should be .dataCorrupted but is: \(error)")
            }
        }
    }

    func testThat_InitializingADrug_WithMissing_application_form_ThrowsAnError() throws {
        let dosages = (String.fixture(), String.fixture(), String.fixture(), String.fixture())
        let dosageForms = "[\"\(dosages.0)\", \"\(dosages.1)\", \"\(dosages.2)\", \"\(dosages.3)\"]"
        let prescriptions = ("prescriptionOnly", "narcotic")
        let prescriptionsArray = "[\"\(prescriptions.0)\", \"\(prescriptions.1)\"]"

        let row = PharmaDatabase.Row.Drug.fixture(application_forms: nil, prescriptions: prescriptionsArray, dosage_forms: dosageForms)

        XCTAssertThrowsError(try DrugReference(row: row), "Should throw error: Invalid json") {
            guard let error = $0 as? PharmaDatabase.FetchError else {
                return XCTFail("Unexpected error type. Should be PharmaDatabase.FetchError but is: \($0)")
            }
            switch error {
            case .unexpectedNilValue(let table, let column, let id):
                XCTAssertEqual(table, "drug")
                XCTAssertEqual(column, "application_forms")
                XCTAssertEqual(id, row.id)
            default:
                XCTFail("Unexpected state. Should be .unexpectedNilValue but is: \(error)")
            }
        }
    }

}
