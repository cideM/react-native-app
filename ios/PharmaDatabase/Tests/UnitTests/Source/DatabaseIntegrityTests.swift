//
//  DatabaseIntegrityTests.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 30.04.21.
//

import FixtureFactory
import GRDB
import  Domain
@testable import PharmaDatabase
import XCTest

// These tests check if the database mapping tables (agent_section, drug_section) link to missing id's
// It's important that there are no missing references in these tables
// cause this will throw errors during fetching and hence provide no results

// This should normally not be running. It's just meant for occassional checks
// Backend has tests in place to make sure the database is valid
// But for quick checks this might come in handy
// In order to make use of these tests a db file must be copied into the test targets bundle before runnign them
// If the db is missing the test will just be skipped

class DatabaseIntegrityTests: XCTestCase {

    var timestamp = Date().timeIntervalSinceReferenceDate

    // None of the below tests are supposed to actually fail
    // They should rather print to the console whats wrong
    // So it can be inspected and if required forwarded as error report

    func testAgentSections() throws {

        guard let database = try database() else { return }
        print("\n\n🧪 AGENTS:")

        let agents = try database.queue.read { database in
            try PharmaDatabase.Row.AmbossSubstance.fetchAll(database)
        }

        agents.enumerated().forEach { index, agent in
            do {
                _ = try database.substance(for: SubstanceIdentifier(value: agent.id))
                print("✅ (\(index)/\(agents.count)) - \(duration()) - \(agent.id) - \(agent.name!)")
            } catch {
                XCTFail("❌ (\(index)/\(agents.count)) - \(agent.id) - \(agent.name!) - \(error)")
            }
        }
    }

    func testDrugs() throws {

        guard let database = try database() else { return }
        print("\n\n💊 DRUGS:")

        let drugs = try database.queue.read { database in
            try PharmaDatabase.Row.Drug.fetchAll(database)
        }

        drugs.enumerated().forEach { index, drugrow in
            do {
                let drug = try database.drug(for: DrugIdentifier(drugrow.id)!, sorting: .ascending)
                print("✅ (\(index)/\(drugs.count)) - \(duration()) - \(drugrow.id) - \(drug.name)")
            } catch {
                XCTFail("❌ (\(index)/\(drugs.count)) - \(drugrow.id) - \(drugrow.name ?? "❌") - \(error)")
            }
        }
    }

    func testPackages() throws {

        guard let database = try database() else { return }
        print("\n\n💊 PACKAGES:")

        let drugs = try database.queue.read { database in
            try PharmaDatabase.Row.Drug.fetchAll(database)
        }

        drugs.enumerated().forEach { index, drug in
            do {
                print("(\(index + 1)/\(drugs.count)) - \(drug.id) - \((drug.name ?? "❌").uppercased())")
                let drug = try database.drug(for: DrugIdentifier(drug.id)!, sorting: .ascending)
                for (index, package) in drug.pricesAndPackages.enumerated() {
                    let pharmacyPrice = package.pharmacyPrice != nil && !package.pharmacyPrice!.isEmpty ? package.pharmacyPrice! : "❌"
                    let retailPrice = package.recommendedRetailPrice != nil && !package.recommendedRetailPrice!.isEmpty ? package.recommendedRetailPrice! : "❌"
                    var packageSize = "❌"
                    if let size = package.packageSize { packageSize = String(describing: size) }
                    let amount = package.amount.isEmpty ? "❌" : package.amount
                    print("✅ (\(index + 1)/\(drug.pricesAndPackages.count)) - \(duration()) - \(packageSize) - \(amount) - \(package.unit) - \(pharmacyPrice) - \(retailPrice)")
                }
                print("\n")

            } catch {
                XCTFail("❌ (\(index + 1)/\(drugs.count)) - \(drug.id) - \(drug.name!) - \(error)")
            }
        }
    }
}

private extension DatabaseIntegrityTests {

    private func database() throws -> PharmaDatabase? {
        // This test is meant to be run manually occassionally
        // It takes too long to run on CI each time
        // Just download the latest version of the pharma database and add it to the test target
        // in order to skip over this guard statement.
        // (... and dont forget to remove it again once you're done!)
        guard let url = Bundle(for: Self.self).url(forResource: "pharmaDatabase", withExtension: "sqlite") else {
            return nil // -> Just skip this test if no db available
        }

        return try PharmaDatabase(url: url)
    }

    func duration() -> String {
        let now = Date().timeIntervalSinceReferenceDate
        let duration = String(format: "%.4fs", now - timestamp)
        timestamp = now
        return duration
    }
}
