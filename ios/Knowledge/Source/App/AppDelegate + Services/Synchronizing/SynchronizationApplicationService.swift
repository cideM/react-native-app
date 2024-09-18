//
//  UserDataSyncronizationApplicationService.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 12.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import UIKit

final class SynchronizationApplicationService {
    private let allSynchronizers: [Synchronizer]
    private var isSynchronizing = false
    @Inject private var monitor: Monitoring
    @LazyInject var authorizationRepository: AuthorizationRepositoryType
    private var authorizationDidChangeObserver: NSObjectProtocol?
    private var synchronizerNeedsSynchronizationObserver: NSObjectProtocol?
    init(synchronizers: [Synchronizer]) {
        self.allSynchronizers = synchronizers

        authorizationDidChangeObserver = NotificationCenter.default.observe(for: AuthorizationDidChangeNotification.self, object: nil, queue: .main) { [weak self] change in
            if change.newValue == nil, change.oldValue != nil {
                self?.removeAllDataFromLocalStorage()
            } else if change.newValue != nil {
                self?.monitor.info("Start synchronization after login.", context: .synchronization)
                self?.synchronize()
            }
        }

        synchronizerNeedsSynchronizationObserver = NotificationCenter.default.observe(for: SynchronizerNeedsSynchronization.self, object: nil, queue: .main) { [weak self] notification in
            guard let self = self, self.allSynchronizers.contains(where: { $0 === notification.synchronizer }) else { return }
            self.monitor.info("Start synchronization after SynchronizerNeedsSynchronization is triggered.", context: .synchronization)
            self.synchronize(notification.synchronizer)
        }
    }

    private func synchronize(_ singleSynchronizer: Synchronizer? = nil, completion: ((SynchronizationResult) -> Void)? = nil) {
        guard !isSynchronizing else { return }

        isSynchronizing = true
        let dipatchGroup = DispatchGroup()
        var synchronizationResults: [SynchronizationResult] = []

        // A single synchronizer is usually triggered via the "SynchronizerNeedsSynchronization" notification
        // All the synchronizers are usually triggered via "applicationWillEnterForeground" method (below)
        let synchronizersToSync: [Synchronizer]
        if let singleSynchronizer {
            synchronizersToSync = [singleSynchronizer]
        } else {
            synchronizersToSync = allSynchronizers
        }

        synchronizersToSync.forEach { synchronizer in
            dipatchGroup.enter()
            synchronizer.synchronize { synchronizationResult in
                synchronizationResults.append(synchronizationResult)
                dipatchGroup.leave()
            }
        }

        dipatchGroup.notify(queue: .main) { [weak self] in
            let synchronizationResult: SynchronizationResult

            if synchronizationResults.contains(.updated) {
                synchronizationResult = .updated
                self?.monitor.info("Synchronization is complete with new data.", context: .synchronization)
            } else if synchronizationResults.contains(.notUpdated) {
                synchronizationResult = .notUpdated
                self?.monitor.info("Synchronization is complete without new data.", context: .synchronization)
            } else {
                synchronizationResult = .failed
                self?.monitor.info("Synchronization failed.", context: .synchronization)
            }

            completion?(synchronizationResult)
            self?.isSynchronizing = false
        }
    }

    private func removeAllDataFromLocalStorage() {
        isSynchronizing = true
        allSynchronizers.forEach { $0.removeAllDataFromLocalStorage() }
        isSynchronizing = false
    }
}

extension SynchronizationApplicationService: ApplicationService {
    func application(_ application: UIApplicationType, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.setMinimumBackgroundFetchInterval(6 * 60 * 60)
        synchronize()
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplicationType) {
        monitor.info("Start synchronization after the application entered foreground.", context: .synchronization)
        synchronize()
    }

    func application(_ application: UIApplicationType, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        synchronize { synchronizationResult in
            switch synchronizationResult {
            case .updated:
                completionHandler(.newData)
            case .notUpdated:
                completionHandler(.noData)
            case .failed:
                completionHandler(.failed)
            }
        }
    }
}
