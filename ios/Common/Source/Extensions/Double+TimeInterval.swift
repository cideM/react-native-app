//
//  Double+TimeInterval.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 29.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public extension Double {

    /// Returns this Double as TimeInterval in weeks
    var weeks: TimeInterval {
        days * 7
    }

    /// Returns this Double as TimeInterval in days
    var days: TimeInterval {
        hours * 24
    }

    /// Returns this Double as TimeInterval in hours
    var hours: TimeInterval {
        minutes * 60
    }

    /// Returns this Double as TimeInterval in minutes
    var minutes: TimeInterval {
        seconds * 60
    }

    /// Returns this Double as TimeInterval in seconds
    var seconds: TimeInterval {
        TimeInterval(self)
    }
}

/// These Extensions are just for better grammar.
public extension Double {

    /// Returns this Double as TimeInterval in weeks
    var week: TimeInterval {
        weeks
    }

    /// Returns this Double as TimeInterval in days
    var day: TimeInterval {
        days
    }

    /// Returns this Double as TimeInterval in hours
    var hour: TimeInterval {
        hours
    }

    /// Returns this Double as TimeInterval in minutes
    var minute: TimeInterval {
        minutes
    }

    /// Returns this Double as TimeInterval in seconds
    var second: TimeInterval {
        seconds
    }
}
