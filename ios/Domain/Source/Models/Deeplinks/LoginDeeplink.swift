//
//  LoginDeeplink.swift
//  Interfaces
//
//  Created by Cornelius Horstmann on 09.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct LoginDeeplink: Equatable {

    // sourcery: fixture:
    public init() {}

    public init?(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        self.init(urlComponents: urlComponents)
    }

    public init?(urlComponents: URLComponents) {
        switch urlComponents.pathComponents {
        // /de/app/wissen/login
        case ["de", "app", "wissen", "login"],
            ["app", "wissen", "login"],
            ["us", "app", "knowledge", "login"],
            ["app", "knowledge", "login"]:
            self.init()
        default: return nil
        }
    }
}
