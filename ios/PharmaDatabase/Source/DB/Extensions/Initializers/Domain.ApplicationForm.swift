//
//  Domain.ApplicationForm.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 07.05.21.
//

import Foundation
import GRDB
import Domain

extension Array where Element == Domain.ApplicationForm {

    static func with(row: PharmaDatabase.Row.Drug) throws -> [Domain.ApplicationForm] {

        guard let applicationFormsStrArray = try JSONDecoder().stringArray(from: row.application_forms) else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "drug", column: "application_forms", id: row.id)
        }

        var applicationForms: [ApplicationForm] = []
        try applicationFormsStrArray.forEach { applicationForm in
            switch applicationForm {
            case "enteral": applicationForms.append(.enteral)
            case "parenteral": applicationForms.append(.parenteral)
            case "topical": applicationForms.append(.topical)
            case "ophthalmic": applicationForms.append(.ophthalmic)
            case "inhalation": applicationForms.append(.inhalation)
            case "rectal": applicationForms.append(.rectal)
            case "nasal_spray": applicationForms.append(.nasalSpray)
            case "urogenital": applicationForms.append(.urogenital)
            case "bronchial": applicationForms.append(.bronchial)
            case "other": applicationForms.append(.other)
            default:
                throw PharmaDatabase.FetchError.unexpectedJSONValue(table: "drug", column: "application_forms", id: row.id, jsonKey: "application_forms", unexpectedValue: applicationForm)
            }
        }

        return applicationForms
    }
}
