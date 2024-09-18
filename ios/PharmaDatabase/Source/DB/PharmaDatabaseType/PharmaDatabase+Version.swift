//
//  PharmaDatabase+PharmaDatabaseType.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 06.04.21.
//

import Foundation
import GRDB
import Domain

public extension PharmaDatabase {

    func version() throws -> Domain.Version {
        let version: Row.Version = try queue.read { database in
            guard let version = try Row.Version.fetchOne(database) else {
                throw FetchError.rowMissing(table: "version")
            }
            return version
        }
        return Domain.Version(major: version.major, minor: version.minor, patch: version.patch)
    }
}
