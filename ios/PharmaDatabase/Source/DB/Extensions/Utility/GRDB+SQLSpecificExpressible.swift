//
//  GRDB+SQL.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 19.04.21.
//

import GRDB

extension GRDB.SQLSpecificExpressible {

    /// This is a covenience function that avoids adding "%" around the search string
    /// "%" is needed as a wildcard indicator for SQLite
    func contains(_ string: String) -> GRDB.SQLExpression {
        self.like("%\(string)%")
    }
}
