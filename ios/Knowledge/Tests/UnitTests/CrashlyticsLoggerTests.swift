//
//  CrashlyticsClientTests.swift
//  KnowledgeTests
//
//  Created by Roberto Seidenberg on 22.07.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import Networking
import XCTest

class CrashlyticsLoggerTests: XCTestCase {

    func testThatSpecificNetworkErrorsAreFilteredOut() {
        let crashlytics = CrashlyticsMonitoringMock()
        let client = CrashlyticsMonitor(crashlytics)
        crashlytics.recordHandler = { _ in
            XCTFail("Error should not be recorded")
        }

        let errors = [
            NetworkError<EmptyAPIError>.noInternetConnection,
            NetworkError<EmptyAPIError>.requestTimedOut,
            NetworkError<EmptyAPIError>.authTokenIsInvalid(String.fixture()),
            NetworkError<EmptyAPIError>.other(String.fixture(), code: URLError.Code.cancelled),
            NetworkError<EmptyAPIError>.other(String.fixture(), code: URLError.Code.timedOut),
            NetworkError<EmptyAPIError>.other(String.fixture(), code: URLError.Code.cannotFindHost),
            NetworkError<EmptyAPIError>.other(String.fixture(), code: URLError.Code.networkConnectionLost),
            NetworkError<EmptyAPIError>.other(String.fixture(), code: URLError.Code.notConnectedToInternet),
            NetworkError<EmptyAPIError>.other(String.fixture(), code: URLError.Code.cannotParseResponse),
            NetworkError<EmptyAPIError>.other(String.fixture(), code: URLError.Code.secureConnectionFailed),
            NetworkError<EmptyAPIError>.other(String.fixture(), code: URLError.Code(rawValue: -1018)), // URLError.Code.somethingWentWrong1
            NetworkError<EmptyAPIError>.other(String.fixture(), code: URLError.Code(rawValue: -1020)), // URLError.Code.somethingWentWrong2
            NetworkError<EmptyAPIError>.other(String.fixture(), code: URLError.Code(rawValue: 8003)) // URLError.Code.cannotConnectOrTimeout
        ]

        for error in errors {
            ([
                QBankAnswerSynchronizer.QBankAnswerSynchronizerError.downloadFailed(error),
                AccessSynchronizer.AccessSynchronizerError.downloadFailed(error),
                SharedExtensionSynchronizer.SharedExtensionSynchronizerError.failedToUpdateUsers(error),
                SharedExtensionSynchronizer.SharedExtensionSynchronizerError.failedToUpdateSharedExtensions(error),
                KillSwitchSynchronizer.KillSwitchSynchronizerError.downloadFailed(error),
                ExtensionSynchroniser.ExtensionSynchroniserError.downloadFailed(error),
                ExtensionSynchroniser.ExtensionSynchroniserError.uploadFailed(error),
                TagSynchroniser.TagSynchroniserError.downloadFailed(error),
                TagSynchroniser.TagSynchroniserError.uploadFailed(error),
                UserDataSynchronizer.UserDataSynchronizerError.failedToFetchCurrentUserData(error),
                UserDataSynchronizer.UserDataSynchronizerError.failedToFetchCurrentUserConfiguration(error),
                ReadingsSynchronizer.ReadingsSynchronizerError.uploadFailed(error),
                UserDataSynchronizer.UserDataSynchronizerError.failedToFetchCurrentUserData(error),
                UserDataSynchronizer.UserDataSynchronizerError.failedToFetchCurrentUserConfiguration(error),
                RemoteConfigSynchError.fetchFailed(error),
                TagSynchroniser.TagSynchroniserError.uploadFailed(error),
                TagSynchroniser.TagSynchroniserError.downloadFailed(error),
                PharmaDatabaseApplicationServiceError.downloadFailed(error),
                ExtensionSynchroniser.ExtensionSynchroniserError.uploadFailed(error),
                ExtensionSynchroniser.ExtensionSynchroniserError.downloadFailed(error)
            ] as [Any]).forEach {
                client.log($0, with: .error, context: .none, file: #file, function: #function, line: #line)
            }
        }
    }

    func testThatOtherNetworkErrorsAreNotFilteredOut() {
        let crashlytics = CrashlyticsMonitoringMock()
        let client = CrashlyticsMonitor(crashlytics)

        let errors: [Any] = [
            NetworkError<EmptyAPIError>.failed(code: String.fixture()),
            NetworkError<EmptyAPIError>.invalidFormat(String.fixture()),
            NetworkError<LoginAPIError>.apiResponseError(.fixture()),
            NetworkError<EmptyAPIError>.other(String.fixture())
        ]

        errors.forEach {
            client.log($0, with: .error, context: .none, file: #file, function: #function, line: #line)
        }

        XCTAssertEqual(crashlytics.recordCallCount, errors.count)
    }

    func testThatOtherErrorTypesAreNotFilteredOut() {
        let crashlytics = CrashlyticsMonitoringMock()
        let client = CrashlyticsMonitor(crashlytics)

        let errors: [Any] = [
            // These are just samples, there are lots more ...
            RemoteConfigSynchError.noFetchYet(nil),
            PharmaDatabaseApplicationServiceError.invalidArchive(NSError.fixture())
        ]

        errors.forEach {
            client.log($0, with: .error, context: .none, file: #file, function: #function, line: #line)
        }

        XCTAssertEqual(crashlytics.recordCallCount, errors.count)
    }
}
