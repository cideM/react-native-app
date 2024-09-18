//
//  Tracer.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 21.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain

/// @mockable
protocol Tracer {
    func startedTrace(name: StaticString, context: MonitorContext) -> Trace
}

extension Tracer {
    func trace<T>(name: StaticString, context: MonitorContext, closure: () throws -> T) throws -> T {
        let trace = startedTrace(name: name, context: context)
        defer { trace.stop() }
        return try closure()
    }
    func trace<T>(name: StaticString, context: MonitorContext, closure: () -> T) -> T {
        let trace = startedTrace(name: name, context: context)
        defer { trace.stop() }
        return closure()
    }
}

/// @mockable
protocol Trace {
    func stop()
    func set(value: String, for attribute: String)
    func set(value: Int64, for metric: String)
}
