//
//  MultiTracer.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 25.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain

class MultiTracer: Tracer {

    let tracers: [Tracer]
    init(tracers: [Tracer]) {
        self.tracers = tracers
    }

    func startedTrace(name: StaticString, context: MonitorContext) -> Trace {
        let traces = tracers.map { $0.startedTrace(name: name, context: context) }
        return MultiTrace(traces: traces)
    }

}

class MultiTrace: Trace {
    let traces: [Trace]
    init(traces: [Trace]) {
        self.traces = traces
    }

    func stop() {
        for trace in traces {
            trace.stop()
        }
    }

    func set(value: String, for attribute: String) {
        for trace in traces {
            trace.set(value: value, for: attribute)
        }
    }

    func set(value: Int64, for metric: String) {
        for trace in traces {
            trace.set(value: value, for: metric)
        }
    }
}
