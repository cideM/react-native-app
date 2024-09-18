//
//  DependencyContainer+TestingBasic.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 23.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import DIKit
import Domain

extension DependencyContainer {
    static var testing = module {
        single { NopMonitor() as Monitoring }
        single { NopTracer() as Tracer }
        single { NopAnalyticsTrackingProvider() as TrackingType }
        single(tag: DIKitTag.Storage.default) { MemoryStorage() as Storage }
        single(tag: DIKitTag.Storage.secure) { MemoryStorage() as Storage }
        single(tag: DIKitTag.Storage.large) { MemoryStorage() as Storage }
        single { NopFeatureFlagRepository() as FeatureFlagRepositoryType }
    }
}

class NopMonitor: Monitoring {
    func log(_ object: @autoclosure () -> Any, with level: MonitorLevel, context: MonitorContext, file: String, function: String, line: UInt) { }
    func shouldLogMessage(with level: MonitorLevel, and context: MonitorContext) -> Bool { false }
}

class NopTracer: Tracer {
    func startedTrace(name: StaticString, context: MonitorContext) -> Trace {
        NopTrace()
    }
}

class NopTrace: Trace {
    func stop() {}
    func set(value: Int64, for metric: String) { }
    func set(value: String, for attribute: String) { }
}

class NopAnalyticsTrackingProvider: TrackingType {
    func set(_ userProperties: [Tracker.UserTraits]) {}
    func update(_ userProperty: Tracker.UserTraits) {}
    func track(_ event: Tracker.Event) {}
}

class MemoryStorage: Storage {
    private var store: [String: Any] = [:]
    func store<T: Codable>(_ value: T?, for key: String) {
        store[key] = value
    }
    func get<T: Codable>(for key: String) -> T? {
        store[key] as? T
    }
}

class NopFeatureFlagRepository: FeatureFlagRepositoryType {
    var featureFlags: [String] = []

    func removeAllDataFromLocalStorage() {

    }
}
