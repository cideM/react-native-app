//
//  DrugTests.swift
//  PharmaDatabaseTests
//
//  Created by Manaf Alabd Alrahim on 12.08.21.
//

import GRDB
import Domain
@testable import PharmaDatabase
import XCTest

class DrugTests: XCTestCase {

    func testThat_InitializingADrug_WithValidData_ReturnsExpectedResult() throws {
        let dosages = (String.fixture(), String.fixture(), String.fixture(), String.fixture())
        let dosageForms = "[\"\(dosages.0)\", \"\(dosages.1)\", \"\(dosages.2)\", \"\(dosages.3)\"]"
        let prescriptions = ("prescriptionOnly", "narcotic")
        let prescriptionsArray = "[\"\(prescriptions.0)\", \"\(prescriptions.1)\"]"

        let row = PharmaDatabase.Row.Drug.fixture(prescriptions: prescriptionsArray, dosage_forms: dosageForms)
        let sectionData: Data = try XCTUnwrap(Data.singleSectionContentJSONData.deflate())
        let section = PharmaDatabase.Row.Section.fixture(content: sectionData)

        let drug = try Drug(row: row, sections: [section], packages: [])

        XCTAssertEqual(drug.eid.value, row.id)
        XCTAssertEqual(drug.name, row.name)
        XCTAssertEqual(drug.vendor, row.vendor)
        XCTAssertEqual(String(describing: drug.prescriptions[0]), prescriptions.0)
        XCTAssertEqual(String(describing: drug.prescriptions[1]), prescriptions.1)
        XCTAssertEqual(drug.sections.first?.title, section.title)
    }

    func testThat_InitializingADrug_WithAMissing_Name_ThrowsAnError() {
        let row = PharmaDatabase.Row.Drug.fixture(name: nil)
        XCTAssertThrowsError(try Drug(row: row, sections: [], packages: []), "Should throw error") {
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

    func testThat_InitializingADrug_WithAMissing_AtcLabel_ThrowsAnError() {
        let row = PharmaDatabase.Row.Drug.fixture(atc_label: nil)
        XCTAssertThrowsError(try Drug(row: row, sections: [], packages: []), "Should throw error") {
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
        XCTAssertThrowsError(try Drug(row: row, sections: [], packages: []), "Should throw error") {
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

        XCTAssertThrowsError(try Drug(row: row, sections: [], packages: []), "Should throw error: Invalid json") {
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

    func testThat_InitializingADrug_WithAMissing_PublishedAtTimestamp_ThrowsAnError() throws {
        let row = PharmaDatabase.Row.Drug.fixture(published_at_ts: nil)
        XCTAssertThrowsError(try Drug(row: row, sections: [], packages: []), "Should throw error") {
            guard let error = $0 as? PharmaDatabase.FetchError else {
                return XCTFail("Unexpected error type. Should be PharmaDatabase.FetchError but is: \($0)")
            }
            switch error {
            case .unexpectedNilValue(let table, let column, let id):
                XCTAssertEqual(table, "drug")
                XCTAssertEqual(column, "published_at_ts")
                XCTAssertEqual(id, row.id)
            default:
                XCTFail("Unexpected state. Should be .unexpectedNilValue but is: \(error)")
            }
        }
    }

    func testThat_InitializingADrug_WithASection_ThatIsMissingItsContent_ThrowsAnError() throws {
        let section = PharmaDatabase.Row.Section.fixture(content: nil)
        let row = PharmaDatabase.Row.Drug.fixture()
        XCTAssertThrowsError(try Drug(row: row, sections: [section], packages: []), "Should throw error") {
            guard let error = $0 as? DecodingError else {
                return XCTFail("Unexpected error type. Should be DecodingError but is: \($0)")
            }
            switch error {
            case .dataCorrupted(let context):
                XCTAssertEqual(context.debugDescription, "The given data was not valid JSON.")
            default:
                XCTFail("Unexpected state. Should be .dataCorrupted but is: \(error)")
            }
        }
    }

    func testThat_InitializingADrug_WithASection_ThatContainsInvalidJSONContent_ThrowsAnError() throws {
        let section = PharmaDatabase.Row.Section.fixture(content: String.fixture().data(using: .utf8))
        let row = PharmaDatabase.Row.Drug.fixture()
        XCTAssertThrowsError(try Drug(row: row, sections: [section], packages: []), "Should throw error") {
            guard let error = $0 as? DecodingError else {
                return XCTFail("Unexpected error type. Should be DecodingError but is: \($0)")
            }
            switch error {
            case .dataCorrupted(let context):
                XCTAssertEqual(context.debugDescription, "The given data was not valid JSON.")
            default:
                XCTFail("Unexpected state. Should be .dataCorrupted but is: \(error)")
            }
        }
    }

    func testThat_InitializingADrug_WithASection_ThatContainsAnInvalidPackage_ThrowsAnError() throws {
        let dosages = (String.fixture(), String.fixture(), String.fixture(), String.fixture())
        let dosageForms = "[\"\(dosages.0)\", \"\(dosages.1)\", \"\(dosages.2)\", \"\(dosages.3)\"]"
        let prescriptions = ("prescriptionOnly", "narcotic")
        let prescriptionsArray = "[\"\(prescriptions.0)\", \"\(prescriptions.1)\"]"

        let package = PharmaDatabase.Row.Package.fixture() // <- Fixture is invalid by default
        let row = PharmaDatabase.Row.Drug.fixture(prescriptions: prescriptionsArray, dosage_forms: dosageForms)

        XCTAssertThrowsError(try Drug(row: row, sections: [], packages: [package]), "Should throw error") {
            guard let error = $0 as? PharmaDatabase.FetchError else {
                return XCTFail("Unexpected error type. Should be DecodingError but is: \($0)")
            }
            switch error {
            case .unexpectedValue(let table, let column, let id, let value):
                XCTAssertEqual(table, "package")
                XCTAssertEqual(column, "package_size")
                XCTAssertEqual(id, String(describing: package.id))
                XCTAssertEqual(value, package.package_size)
            default:
                XCTFail("Unexpected state. Should be .dataCorrupted but is: \(error)")
            }
        }
    }
}
