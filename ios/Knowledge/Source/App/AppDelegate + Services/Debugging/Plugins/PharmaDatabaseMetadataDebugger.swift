//
//  PharmaDatabaseMetadataDebugger.swift
//  Knowledge
//
//  Created by Silvio Bulla on 30.06.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import DeveloperOverlay
import Domain
import PharmaDatabase
import UIKit

class PharmaDatabaseMetadataDebugger: DebuggerPlugin {

    let title = "Current Pharma DB"
    let description: String? = nil

    var pharmaDatabaseApplicationService: PharmaDatabaseApplicationServiceType?

    init(pharmaDatabaseApplicationService: PharmaDatabaseApplicationServiceType? = resolve()) {
        self.pharmaDatabaseApplicationService = pharmaDatabaseApplicationService
    }

    func viewController() -> UIViewController {
        guard let pharmaDatabaseApplicationService = pharmaDatabaseApplicationService as? PharmaDatabaseApplicationService else {
            return UIViewController()
        }

        let pharmaSection = pharmaDatabaseApplicationService.inspectableSection
        return KeyValueDebuggerRootViewController(sectionsGenerator: [pharmaSection].compactMap { $0 })
    }

}

extension PharmaDatabaseApplicationService: KeyValueInspectable {

    public var inspectableSection: KeyValueSection {
        KeyValueSection(title: "Pharma DB version", items: [
            KeyValueItem(key: "major", value: majorVersionEditable),
            KeyValueItem(key: "minor", value: minorVersionEditable),
            KeyValueItem(key: "patch", value: patchVersionEditable)
        ])
    }

    private var majorVersionEditable: EditableValue {
        .int {
            self.pharmaDBVersion.major
        } _: { newValue in
            let newVersion = Version(major: newValue, minor: 0, patch: 0)
            self.pharmaDBVersion = newVersion
        }
    }

    private var minorVersionEditable: EditableValue {
        .int {
            self.pharmaDBVersion.minor
        } _: { newValue in
            let newVersion = Version(major: self.pharmaDBVersion.major, minor: newValue, patch: 0)
            self.pharmaDBVersion = newVersion
        }
    }

    private var patchVersionEditable: EditableValue {
        .int {
            self.pharmaDBVersion.patch
        } _: { newValue in
            let newVersion = Version(major: self.pharmaDBVersion.major, minor: self.pharmaDBVersion.minor, patch: newValue)
            self.pharmaDBVersion = newVersion
        }
    }
}

#endif
