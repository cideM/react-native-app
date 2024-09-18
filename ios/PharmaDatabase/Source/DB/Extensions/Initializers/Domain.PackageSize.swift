//
//  Domain.PackageSize.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 04.05.22.
//

import Foundation
import GRDB
import Domain

extension Domain.PackageSize {

    init?(row: PharmaDatabase.Row.Package) throws {

        guard let packageSizeString = row.package_size, !packageSizeString.isEmpty else {
            return nil
        }

        // Lowercasung this to make it less error prone ...
        let rawValue = packageSizeString.lowercased()

        switch rawValue {
        case "n1": self = .n1
        case "n2": self = .n2
        case "n3": self = .n3
        case "ktp": self = .ktp
        case "notapplicable": self = .notApplicable
        default:
            throw PharmaDatabase.FetchError.unexpectedValue(table: "package", column: "package_size", id: String(describing: row.id), value: packageSizeString)
        }
    }
}
