//
//  LibraryUpdateError.swift
//  Knowledge
//
//  Created by CSH on 20.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

enum LibraryUpdateError: Error {
    case backgroundUpdatesNotAllowed
    case notConnectedToWiFi
    case notConnectedToTheInternet
    case storageExceeded
    case downloadFailed(Error)
    case invalidArchive(Error)

    init(downloadError: Error) {
        switch (downloadError as NSError).code {
        case Int(ENOSPC):
            self = .storageExceeded
        default:
            self = .downloadFailed(downloadError)
        }
    }
}

extension LibraryUpdateError: PresentableMessageType {

    public var debugDescription: String {
        "\(self)"
    }

    public var title: String {
        L10n.Error.Generic.title
    }

    public var body: String {
        switch self {
        case .notConnectedToTheInternet: return L10n.Error.Offline.Library.message
        case .storageExceeded: return L10n.LibrarySettings.UpdateFailed.LackOfStorage.description
        default: return L10n.LibrarySettings.UpdateFailed.SomethingWentWrong.description
        }
    }

    public var logLevel: MonitorLevel {
        switch self {
        case .backgroundUpdatesNotAllowed,
             .notConnectedToWiFi,
             .notConnectedToTheInternet,
             .storageExceeded,
             .downloadFailed:
            return .info

        case .invalidArchive:
            return .warning
        }
    }
}
