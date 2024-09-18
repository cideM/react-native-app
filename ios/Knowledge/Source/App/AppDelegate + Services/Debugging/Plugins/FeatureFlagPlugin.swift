//
//  FeatureFlagPlugin.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 27.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

#if Debug || QA

import DeveloperOverlay
import UIKit

class FeatureFlagPlugin: DebuggerPlugin {
    @Inject private var featureFlagRepository: FeatureFlagRepositoryType
    let title = "Feature Flags"
    let description: String? = "Changes here are not synced with the server. Once the app syncs they will get the server's value back. This is for dev purposes only (not for QA)."

    func viewController() -> UIViewController {
        let featureFlagSection = (featureFlagRepository as? FeatureFlagRepository)?.inspectableSection
        return KeyValueDebuggerRootViewController(sectionsGenerator: [featureFlagSection].compactMap { $0 })
    }
}

extension FeatureFlagRepository: KeyValueInspectable {

    var inspectableSection: KeyValueSection {
        let keys = ["search_pharma_tab", "search_pharma_reranking"]
        let items: [KeyValueItem] = keys.map { key in
            let getter: () -> Bool = { self.featureFlags.contains(key) }
            let setter: (Bool) -> Void = { newValue in
                if newValue, !self.featureFlags.contains(key) {
                    self.featureFlags.append(key)
                } else if !newValue {
                    self.featureFlags.removeAll(where: { $0 == key })
                }
            }
            return KeyValueItem(key: key, value: .bool(getter, setter))
        }
        return KeyValueSection(title: "Feature Flag", items: items)
    }
}

#endif
