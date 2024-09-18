//
//  TestingAppDelegate.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 16.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import DIKit
import Foundation

/// The TestingAppDelegate is only used as an AppDelegate for unit testing purposes.
/// The goal is to have a minimal AppDelegate to save execution time and get better coverage data.
class TestingAppDelegate: NSObject {

    override init() {
        super.init()

        DependencyContainer.defined(by: DependencyContainer.derive(from: [.testing, .librarytesting]))
    }
}
