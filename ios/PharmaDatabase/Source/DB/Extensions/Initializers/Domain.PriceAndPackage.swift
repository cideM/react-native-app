//
//  Domain.PriceAndPackage.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 02.05.22.
//

import Foundation
import GRDB
import Domain

extension Domain.PriceAndPackage {

    init(row: PharmaDatabase.Row.Package) throws {

        guard let amount = row.amount else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "package", column: "amount", id: String(describing: row.id))
        }

        guard let unit = row.unit else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "package", column: "unit", id: String(describing: row.id))
        }

        let packageSize = try PackageSize(row: row)
        let pharmacyPrice = row.pharmacy_price
        let recommendedRetailPrice = row.recommended_price

        self.init(packageSize: packageSize,
                  amount: amount,
                  unit: unit,
                  pharmacyPrice: pharmacyPrice,
                  recommendedRetailPrice: recommendedRetailPrice)
    }
}
