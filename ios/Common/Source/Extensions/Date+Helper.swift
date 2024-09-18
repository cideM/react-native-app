//
//  Date+Helper.swift
//  Common
//
//  Created by CSH on 14.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public extension Date {

    var timeIntervalUntilNow: TimeInterval {
        -timeIntervalSinceNow
    }
}
