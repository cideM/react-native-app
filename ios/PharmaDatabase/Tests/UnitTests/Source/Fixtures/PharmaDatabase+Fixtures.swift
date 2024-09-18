//
//  PharmaDatabase+Fixtures.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 01.04.21.
//

import Foundation
import GRDB
import Domain
@testable import PharmaDatabase

extension PharmaDatabase {

    static func allTables(except: PharmaDatabase.Table? = nil) -> [PharmaDatabase.Table] {
        let tables: [PharmaDatabase.Table] = [
            .version(),
            .ambossSubstance,
            .section,
            .drug,
            .drugSection,
            .package,
            .pocketCard,
            .pocketCardGroup,
            .pocketCardSection,
            .dosage
        ]

        guard let except else { return tables }
        var result = [PharmaDatabase.Table]()
        for table in tables {
            if "\(table)" != "\(except)" {
                result.append(table)
            }
        }
        return result
    }

    static func fixture(with tables: [PharmaDatabase.Table] = allTables(), insert records: [PersistableRecord] = []) throws -> DatabaseQueue {
        let queue = try! DatabaseQueue()
        try queue.write { database in

            for table in tables {
                try table.create(in: database)
                if // Only default to inserting a version if none is provied via "records" argument ...
                    case let Table.version(major, minor, patch, insert) = table,
                    records.contains(where: { $0 is PharmaDatabase.Row.Version }) == false,
                    insert {
                    try PharmaDatabase.Row.Version(id: 1, major: major, minor: minor, patch: patch).insert(database)
                }
            }

            for record in records {
                try record.insert(database)
            }
        }

        return queue
    }
}

extension PharmaDatabase {

    enum Table {
        case version(major: Int = supportedMajorSchemaVersion, minor: Int = supportedMinorSchemaVersion, patch: Int = Int.random(in: 0...Int.max), insert: Bool = true)
        case ambossSubstance
        case section
        case drug
        case drugSection
        case package
        case pocketCard
        case pocketCardGroup
        case pocketCardSection
        case dosage

        func create(in database: GRDB.Database) throws {
            switch self {
            case .version:
                try database.create(table: "version") { table in
                    table.autoIncrementedPrimaryKey("id")
                    table.column("major", .integer)
                    table.column("minor", .integer)
                    table.column("patch", .integer)
                }
            case .ambossSubstance:
                try database.create(table: "amboss_substance") { table in
                    table.column("id", .text)
                    table.column("name", .text)
                    table.column("based_on_drug_id", .text)
                    table.column("prescriptions", .text)
                    table.column("dosage_forms", .text)
                    table.column("published_at_ts", .integer)
                    table.column("search_terms", .text)
                    table.column("suggest_terms", .text)
                    table.column("published", .boolean)
                }
            case .section:
                try database.create(table: "section") { table in
                    table.column("id", .integer)
                    table.column("title", .text)
                    table.column("content", .blob)
                }
            case .drug:
                try database.create(table: "drug") { table in
                    table.column("id", .text)
                    table.column("name", .text)
                    table.column("atc_label", .text)
                    table.column("amboss_substance_id", .text)
                    table.column("vendor", .text)
                    table.column("application_forms", .text)
                    table.column("prescriptions", .text)
                    table.column("dosage_forms", .text)
                    table.column("published_at_ts", .integer)
                    table.column("prescribing_information_url", .text)
                    table.column("patient_package_insert_url", .text)
                    table.column("published", .boolean)
                }
            case .drugSection:
                try database.create(table: "drug_section") { table in
                    table.column("drug_id", .text)
                    table.column("section_id", .text)
                    table.column("position", .integer)
                }
            case .package:
                try database.create(table: "package") { table in
                    table.column("id", .integer)
                    table.column("drug_id", .text)
                    table.column("position_ascending", .integer)
                    table.column("position_mixed", .integer)
                    table.column("package_size", .text)
                    table.column("amount", .text)
                    table.column("unit", .text)
                    table.column("pharmacy_price", .text)
                    table.column("recommended_price", .text)
                    table.column("prescription", .text)
                }
            case .pocketCard:
                try database.create(table: "pocket_card") { table in
                    table.column("id", .text)
                    table.column("amboss_substance_id", .text)
                }
            case .pocketCardGroup:
                try database.create(table: "pocket_card_group") { table in
                    table.column("id", .text)
                    table.column("pocket_card_id", .text)
                    table.column("position", .integer)
                    table.column("title", .text)
                }
            case .pocketCardSection:
                try database.create(table: "pocket_card_section") { table in
                    table.column("id", .text)
                    table.column("pocket_card_group_id", .text)
                    table.column("position", .integer)
                    table.column("title", .text)
                    table.column("content", .text)
                }
            case .dosage:
                try database.create(table: "dosage") { table in
                    table.column("id", .text)
                    table.column("html", .text)
                    table.column("as_link_as_id", .text)
                    table.column("as_link_drug_id", .text)
                }
            }
        }
    }
}
