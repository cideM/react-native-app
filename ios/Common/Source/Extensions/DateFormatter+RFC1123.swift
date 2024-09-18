//
//  DateFormatter+RFC1123.swift
//  Common
//
//  Created by Vedran Burojevic on 02/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public extension DateFormatter {

    static let rfc1123: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss z"
        return dateFormatter
    }()

}
