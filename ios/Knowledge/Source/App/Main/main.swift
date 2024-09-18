//
//  main.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 16.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import UIKit

/// When running unit tests, we want to use a different AppDelegate
/// so we don't have to setup the whole app.
/// We want to do so, in order to have better coverage reporting and
/// to speed up our unit tests.

let isRunningTests = NSClassFromString("XCTestCase") != nil
let appDelegateClass = isRunningTests ? NSStringFromClass(TestingAppDelegate.self) : NSStringFromClass(AppDelegate.self)
_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, appDelegateClass)
