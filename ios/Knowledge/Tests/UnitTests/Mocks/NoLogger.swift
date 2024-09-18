//
//  NoLogger.swift
//  KnowledgeTests
//
//  Created by CSH on 19.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

final class NoLogger: Monitoring {
    func shouldLogMessage(with level: MonitorLevel, and context: MonitorContext) -> Bool {
        false
    }

    func log(_ message: @autoclosure () -> Any, with level: MonitorLevel, context: MonitorContext, file: String, function: String, line: UInt) {
        // Not doing anything here
    }
}
