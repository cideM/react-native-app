//
//  SignpostTracer.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 23.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
import os.signpost

class SignpostTracer: Tracer {
    private let subsystem: String
    init(subsystem: String) {
        self.subsystem = subsystem
    }

    func startedTrace(name: StaticString, context: MonitorContext) -> Trace {
        let signpost = Signpost(osLog: OSLog(subsystem: subsystem, category: context.description), task: name)
        signpost.start()
        return signpost
    }
}

class Signpost: Trace {

    private let osLog: OSLog
    private let task: StaticString

    init(osLog: OSLog, task: StaticString) {
        self.osLog = osLog
        self.task = task
    }

    func start() {
        os_signpost(.begin, log: osLog, name: task)
    }

    func stop() {
        os_signpost(.end, log: osLog, name: task)
    }

    // metrics and attributes not supported now
    func set(value: String, for attribute: String) {}
    func set(value: Int64, for metric: String) {}
}
