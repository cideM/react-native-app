//
//  UserDefaultsPlugin.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 27.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import DeveloperOverlay
import UIKit

class UserDefaultsPlugin: DebuggerPlugin {
    let title = "UserDefaults"
    let description: String? = nil

    func viewController() -> UIViewController {
        let userDefaultsSection = UserDefaults.standard.inspectableSection()
        return KeyValueDebuggerRootViewController(sectionsGenerator: [userDefaultsSection].compactMap { $0 })
    }

}

#endif
