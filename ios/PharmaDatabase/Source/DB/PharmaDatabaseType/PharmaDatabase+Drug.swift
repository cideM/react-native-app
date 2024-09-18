//
//  PharmaDatabase+Drug.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 05.05.21.
//

import Foundation
import GRDB
import Domain

public extension PharmaDatabase {

    func drug(for identifier: DrugIdentifier, sorting: PackageSizeSortingOrder) throws -> Domain.Drug {

        // This uses raw sqlite statements because its much faster
        // When runnng "DatabaseIntegrityTests" the difference is minutes to hours

        guard let drug: PharmaDatabase.Row.Drug = try queue.read({ database in
            let statement = try database.makeStatement(sql: """
                      SELECT * FROM drug WHERE id IS ?
                      """)
            return try Row.Drug.fetchOne(statement, arguments: [identifier.value])

        }) else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "drug", column: "id", id: identifier.value)
        }

        let sections: [PharmaDatabase.Row.Section] = try queue.read { database in
            let statement = try database.makeStatement(sql: """
                      SELECT * FROM section WHERE id IN (
                          SELECT section_id FROM drug_section WHERE drug_id IS ? ORDER BY position ASC
                      )
                      """)
            return try Row.Section.fetchAll(statement, arguments: [identifier.value])
        }

        let packages: [PharmaDatabase.Row.Package] = try queue.read { database in
            let statement = try database.makeStatement(sql: """
                      SELECT * FROM package WHERE drug_id IS ? ORDER BY ? ASC
                      """)

            return try Row.Package.fetchAll(statement, arguments: [
                identifier.value, sorting == .ascending ? "position_ascending" : "position_mixed"
            ])
        }

        return try Domain.Drug(row: drug, sections: sections, packages: packages)
    }
}
