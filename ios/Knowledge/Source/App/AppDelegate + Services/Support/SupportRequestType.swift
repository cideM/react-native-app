//
//  SupportRequestType.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 08.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

internal enum SupportRequestConfiguration {
    case pharma(configuration: Configuration, application: Application, device: Device, deviceId: String, libraryVersionDate: String, agentId: String, drugId: String, lastPharmaSearchQuery: String)
    case monograph(configuration: Configuration, application: Application, device: Device, deviceId: String, libraryVersionDate: String, monographId: String, lastMonographSearchQuery: String)
    case standard(configuration: Configuration, application: Application, device: Device, deviceId: String, libraryVersionDate: String)
}

extension SupportRequestConfiguration {
    internal enum Field {
        case appVersion
        case appOSVersion
        case appDeviceId
        case appDeviceName
        case appLibraryVersionDate
        case pharmaCard
        case searchQuery
        case agent
        case drug
    }
}
