//
//  Monitor.swift
//  Knowledge DE
//
//  Created by Roberto Seidenberg on 10.12.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain

class MultiMonitor: Monitoring {

    let monitors: [Monitoring]

    init(with monitors: [Monitoring]) {
        self.monitors = monitors
    }

    func log(_ message: @autoclosure () -> Any,
             with level: MonitorLevel,
             context: MonitorContext,
             file: String,
             function: String,
             line: UInt) {

        monitors.forEach { logger in
            logger.log(message(), with: level, context: context, file: file, function: function, line: line)
        }
    }
}
