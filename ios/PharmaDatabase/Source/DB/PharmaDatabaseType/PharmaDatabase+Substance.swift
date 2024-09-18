//
//  PharmaDatabase+Agent.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 23.04.21.
//

import Foundation
import GRDB
import Domain

public extension PharmaDatabase {

    func substance(for identifier: SubstanceIdentifier) throws -> Domain.Substance {
        let row: PharmaDatabase.Row.AmbossSubstance? = try queue.read { database in
            let predicate = Row.AmbossSubstance.Columns.id.like(identifier.value)
            return try Row.AmbossSubstance.filter(predicate).fetchOne(database)
        }

        guard let ambossSubstance = row else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "amboss_substance", column: "id", id: identifier.value)
        }

        let drugs: [PharmaDatabase.Row.Drug] = try queue.read { database in
            let predicate = Row.Drug.Columns.amboss_substance_id.like(identifier.value)
            return try Row.Drug.filter(predicate).fetchAll(database)
        }

        var pocketCard: Domain.PocketCard?

        let card: PharmaDatabase.Row.PocketCard? = try queue.read { database in
            let predicate = Row.PocketCard.Columns.amboss_substance_id.like(identifier.value)
            return try Row.PocketCard.filter(predicate).fetchOne(database)
        }

        if let card {
            let groups: [PharmaDatabase.Row.PocketCardGroup]? = try queue.read { database in
                let predicate = Row.PocketCardGroup.Columns.pocket_card_id.like(card.id)
                return try Row.PocketCardGroup.filter(predicate).fetchAll(database)
            }

            guard let groups else {
                throw PharmaDatabase.FetchError.unexpectedNilValue(table: "pocket_card_group", column: "pocket_card_id", id: card.id)
            }

            let groupsWithSections = try groups.map { group in
                let sections: [PharmaDatabase.Row.PocketCardSection] = try queue.read { database in
                    let predicate = Row.PocketCardSection.Columns.pocket_card_group_id.like(group.id)
                    return try Row.PocketCardSection.filter(predicate).fetchAll(database)
                }
                let sortedSections = sections
                    .sorted {
                        $0.position ?? 0 < $1.position ?? 0
                    }
                    .map {
                        PocketCard.Section(title: $0.title, anchor: $0.id, content: $0.content)
                    }
                return PocketCard.Group(title: group.title, anchor: group.id, sections: sortedSections)
            }

            pocketCard = Domain.PocketCard(groups: groupsWithSections)
        }

        return try Domain.Substance(row: ambossSubstance, drugs: drugs, pocketCard: pocketCard)
    }
}
