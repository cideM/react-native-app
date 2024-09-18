//
//  FirebaseTracer.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 20.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import FirebasePerformance

import Domain

final class FirebaseTracer: Tracer {
    func startedTrace(name: StaticString, context: MonitorContext) -> Trace {
        let trace = FirebaseTrace(name: "\(name)")
        trace.start()
        return trace
    }
}

/// Trace is a wrapper for custom firebase performance monitoring
/// https://firebase.google.com/docs/perf-mon/custom-code-traces?hl=en&platform=ios
struct FirebaseTrace: Trace {
    // The trace should in practice never be nil;
    private let trace: FirebasePerformance.Trace?

    init(name: String) {
        trace = Performance.sharedInstance().trace(name: name)
    }

    func set(value: String, for attribute: String) {
        trace?.setValue(value, forAttribute: attribute)
    }

    func set(value: Int64, for metric: String) {
        trace?.setValue(value, forMetric: metric)
    }

    func start() {
        trace?.start()
    }

    func stop() {
        trace?.stop()
    }
}

extension FirebaseTrace {
    enum Name {
        case search
        var rawValue: StaticString {
            switch self {
            case .search: return "search"
            }
        }
    }
    enum Attribute: String {
        case searchScope
        case isOnlineResult
        case onlineErrorCode
    }
    enum Metric: String {
        case requestSize
    }
}

extension Tracer {
    func startedTrace(name: FirebaseTrace.Name, context: MonitorContext) -> Trace {
        startedTrace(name: name.rawValue, context: context)
    }
}

extension Trace {
    func set(value: String, for attribute: FirebaseTrace.Attribute) {
        set(value: value, for: attribute.rawValue)
    }
    func set(value: Int64, for metric: FirebaseTrace.Metric) {
        set(value: value, for: metric.rawValue)
    }
}
