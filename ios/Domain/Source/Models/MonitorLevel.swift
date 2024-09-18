//
//  LogLevel.swift
//  Common
//
//  Created by CSH on 08.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// LogLevel defines a severity of a log message,
public enum MonitorLevel {
    /// Debug can be used to log information for debugging purposes but should not be
    /// extremely verbose about that.
    case debug

    /// Info should be used to log important event that happen in the application, such as:
    /// * user logged in
    /// * user updated
    /// * pushnotification was enabled
    /// * application started/moved to background/...
    case info

    /// Warning should be used for issues that shouldn't happen but can be mitigated in the application.
    case warning

    /// Error should be used for issues that should never happen and cannot be mitigated in the application.
    /// Issues logged using the error log level will lead to unexpected behavior.
    case error
}

extension MonitorLevel: Comparable {

    private var sortableValue: Int {
        switch self {
        case .info: return 1
        case .debug: return 2
        case .warning: return 3
        case .error: return 4
        }
    }

    public static func < (lhs: MonitorLevel, rhs: MonitorLevel) -> Bool {
        lhs.sortableValue < rhs.sortableValue
    }
}
