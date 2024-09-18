//
//  AppConfiguration.swift
//  Knowledge DE
//
//  Created by Roberto Seidenberg on 20.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation

final class AppConfiguration: Configuration {

    static var shared: Configuration {
        guard
            let prefix = Bundle.main.bundleIdentifier?.split(separator: ".").first,
            prefix == "de" || prefix == "us"
        else {
            assertionFailure("None or invalid bundle prefix found! (Must be de or us)")
            return AppConfiguration(variant: .wissen)
        }
        return AppConfiguration(variant: prefix == "de" ? .wissen : .knowledge)
    }

    let appVariant: AppVariant

    private init(variant: AppVariant) {
        self.appVariant = variant
    }

    @available(*, unavailable) private init() {
        fatalError("Initializer not supported")
    }
}
