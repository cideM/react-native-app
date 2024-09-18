//
//  CrashlyticsMontitor.swift
//  Knowledge DE
//
//  Created by Elmar Tampe on 10.05.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import FirebaseCrashlytics

/// @mockable
 protocol CrashlyticsMonitoring {
    func log(_ msg: String)
    func record(error: Error)
 }

extension Crashlytics: CrashlyticsMonitoring {}

final class CrashlyticsMonitor {

    let client: CrashlyticsMonitoring

    init(_ client: CrashlyticsMonitoring = Crashlytics.crashlytics()) {
        self.client = client
    }
}

extension CrashlyticsMonitor: Monitoring {

    static let enabledLogLevels: [MonitorLevel] = [.info, .warning, .error]

    func log(_ object: @autoclosure () -> Any,
             with level: MonitorLevel,
             context: MonitorContext,
             file: String,
             function: String,
             line: UInt) {

        guard shouldLogMessage(with: level, and: context) else { return }
        let object = object()
        let message = String(describing: object)
        client.log(message)
        recordNonFatalError(object, with: level, context: context, file: file, function: function, line: line)
    }
}

extension CrashlyticsMonitor {

    func crashlyticsNSError(object: Any,
                            context: MonitorContext,
                            file: String,
                            function: String,
                            line: UInt) -> NSError {

        let userInfo = [
            "message": String(describing: object),
            "file": file,
            "function": function,
            "line": String(describing: line)
        ]

        var domain: String
        if let string = object as? String {
            domain = string
        } else {
            domain = String(describing: type(of: object))
            // Omit associated values ...
            if let enumCase = String(describing: object).split(separator: "(").first {
                domain = "\(domain).\(enumCase)"
            }
        }

        // There is no info that really fits the "code" slot
        // So we just leave it at "0"
        // Should not make any difference in Crashlytics
        let error = NSError(domain: domain, code: 0, userInfo: userInfo) // -> domain and code from logger context
        return error
    }
}

fileprivate extension CrashlyticsMonitor {

    func shouldLogMessage(with level: MonitorLevel, and context: MonitorContext) -> Bool {
        CrashlyticsMonitor.enabledLogLevels.contains(level)
    }

    func recordNonFatalError(_ object: Any,
                             with level: MonitorLevel,
                             context: MonitorContext,
                             file: String,
                             function: String,
                             line: UInt) {

        guard level == .error else { return }
        if let error = object as? Error, shouldIgnoreError(error) { return }

        let error = crashlyticsNSError(object: object, context: context, file: file, function: function, line: line)
        client.record(error: error)
    }

    func shouldIgnoreError(_ error: Error) -> Bool {
        // ATTENTION!
        // Please see CrashlyticsLoggerTests.testThatSpecificNetworkErrorsAreFilteredOut()
        // and add any error you blacklist here to the tests as well ...

        if let error = error as? QBankAnswerSynchronizer.QBankAnswerSynchronizerError {
            switch error {
            case .downloadFailed(let error): return error.isIgnoredError
            }
        }
        if let error = error as? AccessSynchronizer.AccessSynchronizerError {
            switch error {
            case .downloadFailed(let error): return error.isIgnoredError
            }
        }
        if let error = error as? SharedExtensionSynchronizer.SharedExtensionSynchronizerError {
            switch error {
            case .failedToUpdateUsers(let error),
                    .failedToUpdateSharedExtensions(let error): return error.isIgnoredError
            }
        }
        if let error = error as? KillSwitchSynchronizer.KillSwitchSynchronizerError {
            switch error {
            case .downloadFailed(let error): return error.isIgnoredError
            }
        }
        if let error = error as? ExtensionSynchroniser.ExtensionSynchroniserError {
            switch error {
            case .downloadFailed(let error),
                    .uploadFailed(let error): return error.isIgnoredError
            }
        }
        if let error = error as? TagSynchroniser.TagSynchroniserError {
            switch error {
            case .downloadFailed(let error),
                    .uploadFailed(let error): return error.isIgnoredError
            }
        }
        if let error = error as? UserDataSynchronizer.UserDataSynchronizerError {
            switch error {
            case .failedToFetchCurrentUserData(let error),
                    .failedToFetchCurrentUserConfiguration(let error): return error.isIgnoredError
            }
        }
        if let error = error as? ReadingsSynchronizer.ReadingsSynchronizerError {
            switch error {
            case .uploadFailed(let error): return error.isIgnoredError
            }
        }
        if let error = error as? UserDataSynchronizer.UserDataSynchronizerError {
            switch error {
            case .failedToFetchCurrentUserData(let error),
                    .failedToFetchCurrentUserConfiguration(let error): return error.isIgnoredError
            }
        }
        if let error = error as? RemoteConfigSynchError {
            switch error {
            case .fetchFailed(let error): return error?.isIgnoredError ?? false
            default: break
            }
        }
        if let error = error as? TagSynchroniser.TagSynchroniserError {
            switch error {
            case .uploadFailed(let error),
                    .downloadFailed(let error): return error.isIgnoredError
            }
        }
        if let error = error as? PharmaDatabaseApplicationServiceError {
            switch error {
            case .downloadFailed(let error): return error.isIgnoredError
            default: break
            }
        }
        if let error = error as? ExtensionSynchroniser.ExtensionSynchroniserError {
            switch error {
            case .uploadFailed(let error),
                    .downloadFailed(let error): return error.isIgnoredError
            }
        }

        return false
    }
}

fileprivate extension Error {

    var isIgnoredError: Bool {
        if let error = self as? NetworkError<EmptyAPIError> {
            switch error {
            case .noInternetConnection, .requestTimedOut, .authTokenIsInvalid:
                return true
            case .other(_, let code):
                guard let code = code else { return false }
                switch code {
                    // Most of these error codes are sources from our crashlytics logs
                    // We cant do anything about them and they very likely stem
                    // from all sorts of connection or gateway issues
                    // Hence we filter them out here ...

                    // Connection errors:
                case .cancelled, // -999
                        .timedOut, // -1001
                        .cannotFindHost, // -1003
                        .cannotConnectToHost, // -1004
                        .networkConnectionLost, // -1005
                        .notConnectedToInternet, // -1009
                        .cannotParseResponse: // -1017
                    return true

                    // SSL errors:
                case .secureConnectionFailed: // -1200
                    return true

                    // Esoteric errors:
                case .somethingWentWrong1,
                        .somethingWentWrong2,
                        .cannotConnectOrTimeout:
                    return true

                default:
                    return false
                }
            default:
                break
            }
        }

        return false
    }
}

// None of these errors has a predefined raw value in URLError.Code
// Still those are returned via logging
// Guessing what these mean was done via the accompanying error description in the logs
// We cant fix any of these hence we also filter them ...
fileprivate extension URLError.Code {

    // "Something went wrong with the internet connection"
    static var somethingWentWrong1: URLError.Code { .init(rawValue: -1018) }

    // "Something went wrong with the internet connection"
    static var somethingWentWrong2: URLError.Code { .init(rawValue: -1020) }

    // Triggers for various kinds of connection errors (connectivity, SSL, timeout ...)
    static var cannotConnectOrTimeout: URLError.Code { .init(rawValue: 8003) }
}
