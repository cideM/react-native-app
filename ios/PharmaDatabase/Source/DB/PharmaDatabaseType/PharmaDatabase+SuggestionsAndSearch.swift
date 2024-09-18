//
//  PharmaDatabase+Search.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 19.04.21.
//

import Foundation
import GRDB
import Domain

public extension PharmaDatabase {

    func suggestions(for searchTerm: String, max: Int) throws -> [String] {
        let suggestions: [String] = try queue.read { database in

            let sql = "SELECT * FROM amboss_substance WHERE search_terms LIKE '%\(searchTerm)%' AND published IS true"
            let statement = try database.makeStatement(sql: sql)
            let cursor = try Row.AmbossSubstance.fetchCursor(statement)
            var result = Set<String>()

            while let row = try cursor.next(), result.count <= max {
                let terms = (try JSONDecoder().stringArray(from: row.suggest_terms)?.compactMap { $0 } ?? [])
                    .filter { $0.lowercased() != searchTerm.lowercased() } // -> do not keep suggestions that match search term exactly (ex: covid returns "covid")
                    .sorted { lhs, rhs in lhs.localizedCompare(rhs) == .orderedAscending }

                for term in terms {
                    result.insert(term)
                }
            }

            return Array(result)
        }

        return suggestions
    }

    func items(for searchTerm: String) throws -> [PharmaSearchItem] {
        let rows: [PharmaDatabase.Row.AmbossSubstance] = try queue.read { database in
            let substance = Row.AmbossSubstance.Columns.self
            let names = try Row.AmbossSubstance
                .filter(substance.name.contains(searchTerm))
                .filter(substance.published)
                .fetchAll(database)
            return names
        }

        let items: [(name: String, item: Domain.PharmaSearchItem)] = try rows.map { row in
            guard let name = row.name else {
                throw PharmaDatabase.FetchError.unexpectedNilValue(table: "amboss_substance", column: "name")
            }
            guard let basedOnDrugId = row.based_on_drug_id else {
                throw PharmaDatabase.FetchError.unexpectedNilValue(table: "amboss_substance", column: "based_on_drug_id")
            }

            let drugRow: PharmaDatabase.Row.Drug? = try queue.read { database in
                let predicate = Row.Drug.Columns.id.like(basedOnDrugId)
                let drug = try Row.Drug.filter(predicate).fetchOne(database)
                return drug
            }

            guard let drug = drugRow else {
                throw PharmaDatabase.FetchError.unexpectedNilValue(table: "drug", column: "id", id: basedOnDrugId)
            }

            return (name: name, item: try Domain.PharmaSearchItem(row: row, basedOnDrug: drug, highlight: searchTerm))
        }

        // Items which contain the search term in its title are shown at the top
        // Sorted by length of title (ex: "Ramipril" above "Amlodipin | Ramipril")
        // Everything else at the bottom, also sorted by length of title
        let itemsWithSearchTermInTitle = items.filter { name, _ in name.lowercased().contains(searchTerm.lowercased()) == true }.sortByLengthAndMap()
        let itemsWithoutSearchTermInTitle = items.filter { name, _ in name.lowercased().contains(searchTerm.lowercased()) == false }.sortAcendingAndMap()
        let result = itemsWithSearchTermInTitle + itemsWithoutSearchTermInTitle

        return result
    }
}

private extension Array where Element == (name: String, item: Domain.PharmaSearchItem) {
    func sortByLengthAndMap() -> [PharmaSearchItem] {
        self.sorted { lhs, rhs in
            if lhs.name.count == rhs.name.count {
                return lhs.name.localizedCompare(rhs.name) == .orderedAscending
            } else {
                return lhs.name.count < rhs.name.count
            }
        }
        .map { _, item in item }
    }

    func sortAcendingAndMap() -> [PharmaSearchItem] {
        self.sorted { lhs, rhs in
            lhs.name.localizedCompare(rhs.name) == .orderedAscending
        }
        .map { _, item in item }
    }
}
