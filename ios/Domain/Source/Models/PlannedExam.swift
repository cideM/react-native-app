//
//  PlannedExam.swift
//  Interfaces
//
//  Created by CSH on 13.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

/// The PlannedExam models an exam that is setup on the server for the user to select as the exam they are working towards.
/// It is, as of for today, only used and provided on the DE platform.
///
public struct PlannedExam: Equatable {
    public let eid: String
    public let name: String

    /// sourcery: fixture: 
    public init(eid: String, name: String) {
        self.eid = eid
        self.name = name
    }
}

public extension PlannedExam {

    /// In the US version, the eid of a planned exam object will be the date of that exam in this format: "EEE MMM dd 00:00:00 'GMT+00:00' yyyy".
    private static let usEidDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd 00:00:00 'GMT+00:00' yyyy"
        return dateFormatter
    }()

    /// In the US version, the name of a planned exam object will be the date of that exam in this format: "mm - yyyy" (eg. 03 - 2020).
    private static let usNameDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "MM - yyyy"
        return dateFormatter
    }()

    /// Initializes a `PlannedExam` with a date object and uses the appropriate formatters to set the properties of the planned exam.
    init(usDate date: Date) {
        eid = PlannedExam.usEidDateFormatter.string(from: date)
        name = PlannedExam.usNameDateFormatter.string(from: date)
    }
}
