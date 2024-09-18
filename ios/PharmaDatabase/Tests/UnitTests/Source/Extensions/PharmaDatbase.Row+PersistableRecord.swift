//
//  PharmaDatbase.Row+Fixtures.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 06.04.21.
//

import FixtureFactory
import Foundation
import GRDB
@testable import PharmaDatabase

// Amend insertion methods to rows
// This is required to populate mock databases during testing
extension PharmaDatabase.Row.Version: PersistableRecord {}
extension PharmaDatabase.Row.Agent: PersistableRecord {}
