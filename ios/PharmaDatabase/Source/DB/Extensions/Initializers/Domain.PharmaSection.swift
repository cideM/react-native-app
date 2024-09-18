//
//  Domain.Agent.PharmaSection+Init.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 23.04.21.
//

import Foundation
import GRDB
import Domain

extension Domain.PharmaSection {

    init(row: PharmaDatabase.Row.Section, position: Int) throws {
        guard let title = row.title else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "section", column: "title", id: String(row.id))
        }

        guard
            let compressed = row.content,
            let uncompressed = compressed.inflate(),
            let text = String(data: uncompressed, encoding: .utf8)
        else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "section", column: "content", id: String(row.id))
        }

        self.init(title: title, text: text, position: position)
    }
}
