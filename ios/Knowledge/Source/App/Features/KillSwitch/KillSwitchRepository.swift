//
//  KillSwitchRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 21.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Networking

protocol KillSwitchRepositoryType {
    var deprecationStatus: KillSwitchDeprecationStatus { get }
    func updateDeprecationStatus(with deprecationItems: [DeprecationItem]) -> Bool
}

final class KillSwitchRepository: KillSwitchRepositoryType {
    private let storage: Storage

    init(storage: Storage, application: Application = Application.main) {
        self.storage = storage
        self.application = application
    }

    private let application: Application
    var deprecationStatus: KillSwitchDeprecationStatus {
        get {
            storage.get(for: .deprecationStatus) ?? .notDeprecated
        }
        set {
            let oldValue = deprecationStatus
            storage.store(newValue, for: .deprecationStatus)
            NotificationCenter.default.post(KillSwitchDeprecationStatusDidChangeNotification(oldValue: oldValue, newValue: newValue), sender: self)
        }
    }

    func updateDeprecationStatus(with deprecationItems: [DeprecationItem]) -> Bool {
        let matchingDepricationItems = deprecationItems
            .filter {
                $0.platform == .ios &&
                    $0.type == .unsupported &&
                    $0.identifier == application.bundleIdentifier &&
                    isApplicationVersionInRange(minVersion: $0.minVersion, maxVersion: $0.maxVersion)
            }

        let deprecationStatus: KillSwitchDeprecationStatus
        if let matchingDeprecationItem = matchingDepricationItems.first {
            deprecationStatus = .deprecated(matchingDeprecationItem.url ?? URL(string: "https://next.amboss.com")!) // // swiftlint:disable:this force_unwrapping
        } else {
            deprecationStatus = .notDeprecated
        }

        defer {
            self.deprecationStatus = deprecationStatus
        }

        return deprecationStatus == self.deprecationStatus
    }

    private func isApplicationVersionInRange(minVersion: String, maxVersion: String) -> Bool {
        guard let applicationVersion = application.version else { assertionFailure("No application version found."); return false }

        let minVersionComparisonResult = applicationVersion.compare(minVersion)
        let maxVersionComparisonResult = applicationVersion.compare(maxVersion)

        return (minVersionComparisonResult == .orderedDescending || minVersionComparisonResult == .orderedSame) &&
            (maxVersionComparisonResult == .orderedAscending || maxVersionComparisonResult == .orderedSame)
    }
}
