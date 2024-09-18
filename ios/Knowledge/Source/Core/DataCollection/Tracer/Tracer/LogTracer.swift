//
//  LogTracer.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 25.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

class LogTracer: Tracer {
    func startedTrace(name: StaticString, context: MonitorContext) -> Trace {
        let signpost = LogTrace(task: name, context: context)
        signpost.start()
        return signpost
    }
}

class LogTrace: Trace {

    @Inject private var monitor: Monitoring
    private var startDate = Date()
    private let task: StaticString
    private let context: MonitorContext

    init(task: StaticString, context: MonitorContext) {
        self.task = task
        self.context = context
    }

    func start() {
        startDate = Date()
    }

    func stop() {
        let duration = Date().timeIntervalSince(startDate)
        monitor.info("DURATION of \(task): \(String(format: "%.4fs", duration))", context: context)
    }

    func set(value: String, for attribute: String) {}
    func set(value: Int64, for metric: String) {}
}
