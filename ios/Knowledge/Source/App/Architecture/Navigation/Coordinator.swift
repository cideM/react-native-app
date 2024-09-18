//
//  Coordinator.swift
//  Knowledge
//
//  Created by CSH on 11.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import UIKit

/// @mockable
protocol Coordinator: AnyObject {

    var rootNavigationController: UINavigationController { get }

    /// The `start()` function should setup the UI of the feature.
    /// After this function was called, the UI should be visible and ready to be used by the user.
    func start(animated: Bool)

    /// The  `stop()` function should revert all changes this coordinator did to the UI.
    /// This should include but isn't limited to
    /// * poping all ViewControllers from the UINavigationController it added
    /// * dismissing all ViewControllers it presented
    /// * stopping all child coordinators
    func stop(animated: Bool)
}
