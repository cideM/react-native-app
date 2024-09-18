//
//  URL+QueryItems.swift
//  Common
//
//  Created by CSH on 12.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// In theory there are situations where these methods simply return the unchanged url.
/// Those cases are rare (we aren't aware of any) and are because of a weird, malformed url.
public extension URL {

    /// Returns a new url where new URLQueryItem are added.
    ///
    /// - Parameter query: A dictionary representing query items to add.
    /// - Returns: A new URL.
    func adding(query items: [String: String]) -> URL {
        let newQueryItems = URLQueryItem.items(items)
        let existingQueryItems = self.queryItems().filter { !items.keys.contains($0.name) }
        return setting(existingQueryItems + newQueryItems)
    }

    /// Returns a new url where all URLQueryItem are replaced.
    ///
    /// - Parameter query: A dictionary representing query items to set.
    /// - Returns: A new URL.
    func setting(query items: [String: String]) -> URL {
        setting(URLQueryItem.items(items))
    }

    func setting(queryItemValue value: String?, for name: String) -> URL {
        let existingQueryItems = self.queryItems().filter { $0.name != name }
        if let value = value {
            let queryItem = URLQueryItem(name: name, value: value)
            return setting(existingQueryItems + [queryItem])
        } else {
            return setting(existingQueryItems)
        }
    }

    /// Calculates and returns an array of URLQueryItems.
    ///
    /// - Returns: An Array of URLQueryItems.
    func queryItems() -> [URLQueryItem] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return []
        }
        return components.queryItems ?? []
    }

    /// Filters all queryItems and returns the first with the matching name
    ///
    /// - Parameter name: The name of the queryItems that is searched.
    /// - Returns: The first queryItem that matches the name.
    func queryItem(forName name: String) -> URLQueryItem? {
        queryItems().first { $0.name == name }
    }

    /// Returns a new urls where the fragment is set to a new value.
    /// - Parameter fragment: The new fragment to set
    func setting(fragment: String) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.fragment = fragment
        return components.url ?? self
    }

    /// Returns a new url where all URLQueryItem are replaced.
    ///
    /// - Parameter items: An Array of the new URLQueryItems.
    /// - Returns: A new URL.
    private func setting(_ items: [URLQueryItem]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.queryItems = items
        return components.url ?? self
    }
}

private extension URLQueryItem {

    /// Creates URLQueryItems from a dictionary
    ///
    /// - Parameter dictionary: A flat dictionary with just keys and values to create the url with.
    /// - Returns: An Array of new URLQueryItems.
    static func items(_ dictionary: [String: String]) -> [URLQueryItem] {
        dictionary.map { key, value in URLQueryItem(name: key, value: value) }
    }
}
