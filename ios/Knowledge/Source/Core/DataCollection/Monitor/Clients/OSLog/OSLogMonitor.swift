//
//  OSLogMonitor.swift
//  Knowledge DE
//
//  Created by Roberto Seidenberg on 07.05.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import OSLog

final class OSLogMonitor: Monitoring {

    let osLoggers: [MonitorContext: Logger] = {
        MonitorContext.allCases.reduce(into: [MonitorContext: Logger]()) { result, context in
            let subsystem = Bundle.main.bundleIdentifier ?? "knowledge"
            result[context] = Logger(subsystem: subsystem, category: context.description)
        }
    }()

    func log(_ object: @autoclosure () -> Any, with level: MonitorLevel, context: MonitorContext, file: String, function: String, line: UInt) {
        guard let logger = osLoggers[context] else {
            assertionFailure("Logger missing for context: \(context)")
            return
        }

        // WORKAROUND:
        // Taken from here: https://stackoverflow.com/questions/74820139/how-to-use-strings-for-oslogmessage
        // OSLog is supposed to be used without indirection directly at the place of logging
        // String interpolation should as well happen directly inside the function argument scope (privacy reasons)
        // We don't do both of this, hence the very weird syntax here and below
        // `String(describing: message)` must be used directly as an argument and not earlier to assign "message"
        let message = "\(object())"

        switch level {
        case .debug:
            logger.debug("\(String(describing: message))")
        case .info:
            logger.info("\(String(describing: message))")
        case .warning:
            logger.warning("\(String(describing: message))")
        case .error:
            logger.error("\(String(describing: message))")
        }
    }
}
