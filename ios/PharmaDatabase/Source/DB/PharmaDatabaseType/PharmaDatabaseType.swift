//
//  PharmaDatabase+API.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 01.04.21.
//

import Foundation
import Domain

/// @mockable
public protocol PharmaDatabaseType {
    func version() throws -> Domain.Version
    func suggestions(for searchTerm: String, max: Int) throws -> [String]
    func items(for searchTerm: String) throws -> [Domain.PharmaSearchItem]
    func substance(for identifier: SubstanceIdentifier) throws -> Domain.Substance
    func drug(for identifier: DrugIdentifier, sorting: PackageSizeSortingOrder) throws -> Domain.Drug
    func dosage(for identifier: DosageIdentifier) throws -> Domain.Dosage
}

extension PharmaDatabase: PharmaDatabaseType {
    // See files in this directory for protocol conformance:
    // * PharmaDatabase+Version.swift
    // * PharmaDatabase+SuggestionsAndSearch.swift
    // * PharmaDatabase+Agent.swift
    // * PharmaDatabase+Drug
}
