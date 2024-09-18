//
//  Logging.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 16.09.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// @mockable
public protocol Monitoring {
    /// This method should perform the logging.
    ///
    /// - Parameters:
    ///   - message: A closure that produces the message itself.
    ///   - level: The loglevel of the message.
    ///   - context: The context of this log message. This can be used to separate logs for certain areas of the app. 0 means no specific context.
    ///   - file: The filename where the log was created.
    ///   - function: The function where the log was created.
    ///   - line: Then line where the log was created.
    func log(_ object: @autoclosure () -> Any, with level: MonitorLevel, context: MonitorContext, file: String, function: String, line: UInt)
}

public extension Monitoring {
    func debug(_ object: @autoclosure () -> Any, context: MonitorContext, file: String = #file, function: String = #function, line: UInt = #line) {
        log(object(), with: .debug, context: context, file: file, function: function, line: line)
    }
    func info(_ object: @autoclosure () -> Any, context: MonitorContext, file: String = #file, function: String = #function, line: UInt = #line) {
        log(object(), with: .info, context: context, file: file, function: function, line: line)
    }
    func warning(_ object: @autoclosure () -> Any, context: MonitorContext, file: String = #file, function: String = #function, line: UInt = #line) {
        log(object(), with: .warning, context: context, file: file, function: function, line: line)
    }
    func error(_ object: @autoclosure () -> Any, context: MonitorContext, file: String = #file, function: String = #function, line: UInt = #line) {
        log(object(), with: .error, context: context, file: file, function: function, line: line)
    }
}
