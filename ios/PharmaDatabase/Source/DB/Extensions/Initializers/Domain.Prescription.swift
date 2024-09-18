//
//  Domain.Prescription.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 07.05.21.
//

import Foundation
import GRDB
import Domain

extension Array where Element == Domain.Prescription {

    static func with(row: PharmaDatabase.Row.Drug) throws -> [Domain.Prescription] {

        guard let prescriptionsStrArray = try JSONDecoder().stringArray(from: row.prescriptions) else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "drug", column: "prescriptions", id: row.id)
        }

        var prescriptions: [Domain.Prescription] = []
        try prescriptionsStrArray.forEach { prescription in
            switch prescription {
            case "overTheCounter": prescriptions.append(.overTheCounter)
            case "pharmacyOnly": prescriptions.append(.pharmacyOnly)
            case "prescriptionOnly": prescriptions.append(.prescriptionOnly)
            case "narcotic": prescriptions.append(.narcotic)
            default:
                throw PharmaDatabase.FetchError.unexpectedJSONValue(table: "drug", column: "prescriptions", id: row.id, jsonKey: "prescriptions", unexpectedValue: prescription)
            }
        }

        return prescriptions
    }
}
