//
//  Synchronizer.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 12.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

enum SynchronizationResult {
    case updated // Updated some data, not failure, possiby a cancellation
    case notUpdated // Finished synchronization, but no data needed to update
    case failed // An error occured while synchronizing (sever error, offline, ...)
}

protocol Synchronizer: AnyObject {
    func synchronize(_ completion: @escaping (SynchronizationResult) -> Void)
    func cancelOperations()
    func removeAllDataFromLocalStorage()
}

extension Synchronizer {
    func cancelOperations() {

    }
}
