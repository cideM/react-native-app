//
//  URLComponents+Helpers.swift
//  Interfaces
//
//  Created by Cornelius Horstmann on 10.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

extension URLComponents {
    var pathComponents: [String] {
        let components = path.components(separatedBy: "/")
        if let first = components.first, first.isEmpty {
            return Array(components.dropFirst())
        }
        return components
    }
    var fragmentQueryItems: [URLQueryItem]? {
        URLComponents(string: "?\(fragment ?? "")")?.queryItems
    }
}
