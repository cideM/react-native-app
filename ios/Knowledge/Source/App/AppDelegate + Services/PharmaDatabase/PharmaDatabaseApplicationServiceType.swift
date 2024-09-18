//
//  PharmaDatabaseApplicationServiceType.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 01.04.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import PharmaDatabase

// sourcery: fixture:
enum PharmaDatabaseUpdateType {
    case manual
    case automatic
}

enum PharmaDatabaseApplicationServiceState {
    case idle(error: PharmaDatabaseApplicationServiceError?, availableUpdate: PharmaUpdate?, type: PharmaDatabaseUpdateType)
    case checking
    case downloading(update: PharmaUpdate, progress: Double)
    case installing
}

enum PharmaDatabaseApplicationServiceError: Error {
    case busy
    case updateNotAllowed
    case notConnectedToWiFi
    case notConnectedToTheInternet
    case storageExceeded
    case downloadFailed(Error)
    case invalidArchive(Error)
    case noDatabaseToUpdate
    case canceled

    init(error: Error) {
        switch error {
        case PharmaUpdaterError.downloaderError(let error):
            self = PharmaDatabaseApplicationServiceError(updaterError: .downloaderError(error))
        case PharmaUpdaterError.unzippingFailed(let error):
            self = PharmaDatabaseApplicationServiceError(updaterError: .unzippingFailed(error))
        case PharmaUpdaterError.canceled:
            self = .canceled
        default:
            self = PharmaDatabaseApplicationServiceError(updaterError: .underlyingError(error: error))
        }
    }

    init(updaterError: PharmaUpdaterError) {
        switch updaterError {
        case .downloaderError(let downloaderError):
            switch downloaderError {
            case .fileSystem(underlying: let error):
                if (error as NSError).code == Int(ENOSPC) {
                    self = .storageExceeded
                } else {
                    self = .downloadFailed(updaterError)
                }
            default:
                self = .downloadFailed(updaterError)
            }
        case .unzippingFailed(let unzippingError):
            switch unzippingError {
            case .storageExceeded:
                self = .storageExceeded
            case .other(let error):
                self = .invalidArchive(error)
            }
        default:
            self = .downloadFailed(updaterError)
        }
    }
}

/// @mockable
protocol PharmaDatabaseApplicationServiceType: ApplicationService {
    var pharmaDatabase: PharmaDatabaseType? { get }
    var state: PharmaDatabaseApplicationServiceState { get }
    var isBackgroundUpdatesEnabled: Bool { get set }
    var featureFlagRepository: FeatureFlagRepositoryType { get }

    func checkForUpdate() throws
    func startManualUpdate() throws
    func startAutomaticUpdate() throws
    func deleteDatabase() throws

    #if DEBUG
    /// This is only used inside the `Developer Overlay` for debugging purposes.
    var pharmaDBVersion: Version { get set }
    #endif

}
