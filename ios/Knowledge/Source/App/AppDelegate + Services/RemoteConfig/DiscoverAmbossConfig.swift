//
//  DiscoverAmbossConfig.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 16.12.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

struct DiscoverAmbossConfig: Decodable, Equatable {
    private let drugReferences: [Item] // Depending on the target, this can be an array of either Pharma / Monograph items
    private let articleReferences: [Item]

    let calculators: Item
    let algorithms: Item

    var leftDrugReference: Item { drugReferences[0] }
    var rightDrugReference: Item { drugReferences[1] }

    var leftArticleReference: Item { articleReferences[0] }
    var rightArticleReference: Item { articleReferences[1] }

    private enum CodingKeys: String, CodingKey {
        case drugReferences = "drug_references"
        case articleReferences = "article_references"
        case calculators
        case algorithms
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let drugReferences = try container.decode([Item].self, forKey: .drugReferences)
        guard drugReferences.count == 2 else { throw Error.invalidDrugReferencesCount }
        self.drugReferences = drugReferences

        let articleReferences = try container.decode([Item].self, forKey: .articleReferences)
        guard articleReferences.count == 2 else { throw Error.invalidArticleReferencesCount }
        self.articleReferences = articleReferences

        self.calculators = try container.decode(Item.self, forKey: .calculators)
        self.algorithms = try container.decode(Item.self, forKey: .algorithms)
    }

    // sourcery: fixture:
    init(drugReferences: [Item], articleReferences: [Item], calculators: Item, algorithms: Item) {
        self.drugReferences = drugReferences
        self.articleReferences = articleReferences
        self.calculators = calculators
        self.algorithms = algorithms
    }
}

extension DiscoverAmbossConfig {
    enum Error: Swift.Error {
        case invalidDrugReferencesCount
        case invalidArticleReferencesCount
    }
}

extension DiscoverAmbossConfig {
    struct Item: Decodable, Equatable {
        let title: String
        let deepLink: Deeplink
        let url: URL // The url here is only needed for tracking purposes

        // sourcery: fixture:
        init(title: String, deepLink: Deeplink, url: URL) {
            self.title = title
            self.deepLink = deepLink
            self.url = url
        }

        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case title
            case deepLink = "link"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            title = try container.decode(String.self, forKey: .title)

            url = try container.decode(URL.self, forKey: .deepLink)
            deepLink = Deeplink(url: url)
        }
    }
}
