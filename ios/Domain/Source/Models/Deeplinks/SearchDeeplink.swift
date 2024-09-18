//
//  SearchDeeplink.swift
//  Interfaces
//
//  Created by Merve Kavaklioglu on 02.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct SearchDeeplink: Equatable {

    public let type: SearchType
    public let query: String
    public let filter: String?

    // sourcery: fixture:
    public init(type: SearchType, query: String, filter: String? = nil) {
        self.type = type
        self.query = query
        self.filter = filter
    }

    init?(type: String, query: String, filter: String? = nil) {
        self.query = query
        self.filter = filter
        switch type {
        case "article": self.type = .article
        case "pharma": self.type = .pharma
        case "overview": self.type = .all
        case "guideline": self.type = .guideline
        case "media": self.type = .media
        default: return nil
        }
    }

    public init?(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        self.init(urlComponents: urlComponents)
    }

    public init?(urlComponents: URLComponents) {
        switch urlComponents.pathComponents {
        // /us/search/?q:query&v:type
        case ["us", "search"],
            ["de", "search"]:
            guard let query = urlComponents.queryItems?["q"] else { return nil }
            let type = urlComponents.queryItems?["v"] ?? "overview"

            // Link can have multiple filters defined, we use the first one only
            let filter = urlComponents.queryItems?["mtype"]

            self.init(type: type, query: query, filter: filter)
        case ["us", "search", .any],
            ["de", "search", .any]:
            let query = urlComponents.pathComponents[2]
            let type = urlComponents.queryItems?["v"] ?? "overview"

            // Link can have multiple filters defined, we use the first one only
            let filter = urlComponents.queryItems?["mtype"]

            self.init(type: type, query: query, filter: filter)
        default:
            return nil
        }
    }

}

// sourcery: fixture:
public enum SearchType {
    case all
    case article
    case pharma
    case guideline
    case media
}
