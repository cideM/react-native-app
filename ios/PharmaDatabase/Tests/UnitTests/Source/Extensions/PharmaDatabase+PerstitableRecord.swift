//
//  PharmaDatabase+PerstitableRecord.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 30.04.21.
//

import GRDB
@testable import PharmaDatabase

// This is required to populate test databases
// Records are not "writable" by default
extension PharmaDatabase.Row.Version: PersistableRecord {}
extension PharmaDatabase.Row.AmbossSubstance: PersistableRecord {}
extension PharmaDatabase.Row.Section: PersistableRecord {}
extension PharmaDatabase.Row.Drug: PersistableRecord {}
extension PharmaDatabase.Row.DrugSection: PersistableRecord {}
extension PharmaDatabase.Row.Dosage: PersistableRecord {}
