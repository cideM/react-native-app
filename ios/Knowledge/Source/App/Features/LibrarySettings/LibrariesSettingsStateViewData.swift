//
//  LibrariesSettingsStateViewData.swift
//  Knowledge
//
//  Created by CSH on 22.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

enum LibrariesSettingsStateViewData {
    enum StateViewData {
        case checking
        case upToDate
        case downloading(Progress)
        case installing
        case outdated(_ updateByteSize: Int, isPharmaDatabaseAlreadyInstalled: Bool?)
        case failed(_ updateByteSize: Int?, _ title: String, _ description: String)
    }

    case library(StateViewData)
    case pharma(StateViewData)
}
