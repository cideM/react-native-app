//
//  UserdataPlugin.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 27.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import DeveloperOverlay
import UIKit

class UserdataPlugin: DebuggerPlugin {
    @Inject private var userDataRepository: UserDataRepositoryType
    let title = "Userdata"
    let description: String? = nil

    func viewController() -> UIViewController {
        let userDataSection = (userDataRepository as? UserDataRepository)?.inspectableSection
        return KeyValueDebuggerRootViewController(sectionsGenerator: [userDataSection].compactMap { $0 })
    }

}

extension UserDataRepository: KeyValueInspectable {
    var inspectableSection: KeyValueSection {
        let items: [KeyValueItem] = [
            KeyValueItem(key: "userStage", value: userStage),
            KeyValueItem(key: "studyObjective", value: studyObjective)
        ]
        return KeyValueSection(title: "User Data", items: items)
    }
}

#endif
