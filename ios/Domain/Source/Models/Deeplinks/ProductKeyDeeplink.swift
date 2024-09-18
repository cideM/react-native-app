//
//  CouponCodeDeeplink.swift
//  Domain
//
//  Created by Roberto Seidenberg on 22.01.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct ProductKeyDeeplink: Equatable {

    public let code: String

    public init?(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        self.init(urlComponents: urlComponents)
    }

    public init?(urlComponents: URLComponents) {
        switch urlComponents.pathComponents {
        // /us/campuslicense/add?key=ST8CVVM2YCNQ
        case ["us", "campuslicense", "add"]:
            guard
                let query = urlComponents.queryItems,
                query.first?.name == "key",
                let code = query.first?.value,
                code.count > 0
            else { return nil }
            self.init(code: code)
        //  /de/account/accessChooser?key=ST8CVVM2YCNQ
        case ["de", "account", "accessChooser"]:
            guard
                let query = urlComponents.queryItems,
                query.first?.name == "key",
                let code = query.first?.value,
                code.count > 0
            else { return nil }
            self.init(code: code)
        default:
            return nil
        }
    }

    // sourcery: fixture:
    init(code: String) {
        self.code = code
    }
}
