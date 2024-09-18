////
////  LibraryUpdateApplicationServiceTest.swift
////  KnowledgeTests
////
////  Created by Silvio Bulla on 04.02.20.
////  Copyright © 2020 AMBOSS GmbH. All rights reserved.
////
//
//import Domain
//@testable import Knowledge_DE
//import XCTest
//
//class LibraryUpdateApplicationServiceTest: XCTestCase {
//
//    var learningCardClient: LearningCardLibraryClientMock!
//    var libraryUpdateApplicationService: LibraryUpdateApplicationService!
//    var libraryRepository: LibraryRepositoryTypeMock!
//    var accessRepository: AccessRepositoryTypeMock!
//    var tempWorkingFolder: URL!
//    var storage: MemoryStorage!
//    var trackingProvider: TrackingTypeMock!
//
//    override func setUp() {
//        learningCardClient = LearningCardLibraryClientMock()
//        learningCardClient.checkForLibraryUpdateHandler = { _, completion in completion(.failure(.other("mocked"))) }
//        libraryRepository = LibraryRepositoryTypeMock()
//        accessRepository = AccessRepositoryTypeMock()
//        libraryRepository.library = try! Library.Fixture.valid()
//        tempWorkingFolder = FileManager.default.temporaryDirectory.appendingPathComponent("LibraryUpdateApplicationServiceTest-tempWorkingFolder")
//        storage = MemoryStorage()
//        trackingProvider = TrackingTypeMock()
//        try! FileManager.default.createDirectory(at: tempWorkingFolder, withIntermediateDirectories: true)
//
//        libraryUpdateApplicationService = LibraryUpdateApplicationService(
//            learningCardClient: learningCardClient,
//            storage: storage,
//            trackingProvider: trackingProvider,
//            libraryRepository: libraryRepository,
//            accessRepository: accessRepository,
//            cleaner: LibraryUpdaterLegacyCleanerTypeMock())
//    }
//
//    override func tearDown() {
//        try? FileManager.default.removeItem(at: libraryRepository.library.url)
//        try? FileManager.default.removeItem(at: tempWorkingFolder)
//        try? FileManager.default.removeItem(at: resolve(tag: .libraryRoot))
//    }
//
//    func testThatANewUpdateWillNotBeStartedWhenACurrentUpdateIsCurrentlyChecking() {
//        let expectation = expectation(description: "Library update should only be triggered once")
//        learningCardClient.checkForLibraryUpdateHandler = { _, _ in
//            expectation.fulfill() // Should be called only once
//        }
//        libraryUpdateApplicationService.initiateUpdate(isUserTriggered: true)
//        libraryUpdateApplicationService.initiateUpdate(isUserTriggered: true)
//        wait(for: [expectation], timeout: 0.5)
//    }
//
//    func testThatANewUpdateWillNotBeStartedWhenACurrentUpdateIsCurrentlyDownloading() {
//        let expectation = expectation(description: "Library update should only be triggered once")
//        learningCardClient.checkForLibraryUpdateHandler = { _, completion in
//            completion(.success(LibraryUpdate.fixture()))
//            expectation.fulfill() // Should be called only once
//        }
//        libraryUpdateApplicationService.initiateUpdate(isUserTriggered: true)
//        libraryUpdateApplicationService.initiateUpdate(isUserTriggered: true)
//        wait(for: [expectation], timeout: 0.5)
//    }
//
//    func testThatANewUpdateRequestCanUpgradeACurrentUpdateRequestToAManualOne() {
//        learningCardClient.checkForLibraryUpdateHandler = { _, _ in }
//
//        libraryUpdateApplicationService.initiateUpdate(isUserTriggered: false)
//        if case .checking(false) = libraryUpdateApplicationService.state { } else {
//            XCTFail("Unexpected state after the first update request")
//        }
//
//        libraryUpdateApplicationService.initiateUpdate(isUserTriggered: true)
//        if case .checking(true) = libraryUpdateApplicationService.state {
//        } else {
//            XCTFail("Unexpected state after the first update request")
//        }
//    }
//
//    func testThatAnUpdateWillAlwaysBeStartedWhenTheAppIsInForegroundAnNoUserInteractionDateWasSaved() {
//        let expectation = expectation(description: "Should check for update if app is active")
//        learningCardClient.checkForLibraryUpdateHandler = { _, _ in
//            expectation.fulfill()
//        }
//        let application = UIApplicationTypeMock(applicationState: .active)
//        _ = libraryUpdateApplicationService.application(application, didFinishLaunchingWithOptions: [:])
//        wait(for: [expectation], timeout: 0.5)
//    }
//
//    func testThatAnUpdateWillAlwaysBeStartedWhenTheAppIsInForegroundAndAUserInteractionDateWasSavedThatIsInsideThe7DaysThreshold() {
//        let expectation = expectation(description: "Should check for update if app is active")
//        learningCardClient.checkForLibraryUpdateHandler = { _, _ in
//            expectation.fulfill()
//        }
//
//        let now = Date().timeIntervalSinceReferenceDate
//        let oneDayInSeconds: TimeInterval = 24 * 60 * 60
//        let someDaysAgo = now - (oneDayInSeconds * TimeInterval.random(in: 1...6))
//        let date = Date(timeIntervalSinceReferenceDate: someDaysAgo)
//        storage.store(date, for: .mostRecentUserTriggeredAppLaunchDate)
//
//        let application = UIApplicationTypeMock(applicationState: .active)
//        _ = libraryUpdateApplicationService.application(application, didFinishLaunchingWithOptions: [:])
//        wait(for: [expectation], timeout: 0.5)
//    }
//
//    func testThatAnUpdateWillAlwaysBeStartedWhenTheAppIsInForegroundAndAUserInteractionDateWasSavedThatIsOutsideThe7DaysThreshold() {
//        let expectation = expectation(description: "Should check for update if app is active")
//        learningCardClient.checkForLibraryUpdateHandler = { _, _ in
//            expectation.fulfill()
//        }
//
//        let now = Date().timeIntervalSinceReferenceDate
//        let oneDayInSeconds: TimeInterval = 24 * 60 * 60
//        let someDaysAgo = now - (oneDayInSeconds * TimeInterval.random(in: 7...120))
//        let date = Date(timeIntervalSinceReferenceDate: someDaysAgo)
//        storage.store(date, for: .mostRecentUserTriggeredAppLaunchDate)
//
//        let application = UIApplicationTypeMock(applicationState: .active)
//        _ = libraryUpdateApplicationService.application(application, didFinishLaunchingWithOptions: [:])
//        wait(for: [expectation], timeout: 0.5)
//    }
//
//    func testThatAnUpdateWillBeStartedWhenTheAppIsInBackgroundAndAUserInteractionDateWasSavedThatIsInsideThe7DaysThreshold() {
//        let expectation = expectation(description: "Should check for update if app is active")
//        learningCardClient.checkForLibraryUpdateHandler = { _, _ in
//            expectation.fulfill()
//        }
//
//        let inactiveDays = Int.random(in: 1...6)
//        let lastActiveDate = Calendar.current.date(byAdding: .day, value: -inactiveDays, to: Date())
//        storage.store(lastActiveDate, for: .mostRecentUserTriggeredAppLaunchDate)
//
//        let application = UIApplicationTypeMock(applicationState: .background)
//        _ = libraryUpdateApplicationService.application(application, didFinishLaunchingWithOptions: [:])
//        wait(for: [expectation], timeout: 0.5)
//    }
//
//    func testThatAnUpdateWillNotBeStartedWhenTheAppIsInBackgroundAndAUserInteractionDateWasNotSavedBefore() {
//        let updateExpectation = expectation(description: "Should check for update if app is active")
//        updateExpectation.isInverted = true
//        learningCardClient.checkForLibraryUpdateHandler = { _, _ in
//            updateExpectation.fulfill()
//        }
//
//        let trackingExpectation = expectation(description: "Should track skipped update")
//        trackingProvider.trackHandler = { event in
//            if case let Tracker.Event.library(libraryEvent) = event {
//                switch libraryEvent {
//                case .libraryUpdateSkipped: trackingExpectation.fulfill()
//                default: break
//                }
//            }
//        }
//
//        let application = UIApplicationTypeMock(applicationState: .background)
//        _ = libraryUpdateApplicationService.application(application, didFinishLaunchingWithOptions: [:])
//        wait(for: [updateExpectation, trackingExpectation], timeout: 0.5)
//    }
//
//    func testThatAnUpdateWillNotBeStartedWhenTheAppIsInBackgroundAndAUserInteractionDateWasSavedThatIsOutsideThe7DaysThreshold() {
//        let updateExpectation = expectation(description: "Should check for update if app is active")
//        updateExpectation.isInverted = true
//        learningCardClient.checkForLibraryUpdateHandler = { _, _ in
//            updateExpectation.fulfill()
//        }
//
//        let inactiveDays = Int.random(in: 7...120)
//        let lastActiveDate = Calendar.current.date(byAdding: .day, value: -inactiveDays, to: Date())
//        storage.store(lastActiveDate, for: .mostRecentUserTriggeredAppLaunchDate)
//
//        let trackingExpectation = expectation(description: "Should track skipped update")
//        trackingProvider.trackHandler = { event in
//            if case let Tracker.Event.library(libraryEvent) = event {
//                switch libraryEvent {
//                case .libraryUpdateSkipped(let days):
//                    XCTAssertEqual(days, inactiveDays)
//                    trackingExpectation.fulfill()
//                default: break
//                }
//            }
//        }
//
//        let application = UIApplicationTypeMock(applicationState: .background)
//        _ = libraryUpdateApplicationService.application(application, didFinishLaunchingWithOptions: [:])
//        wait(for: [updateExpectation, trackingExpectation], timeout: 0.5)
//    }
//
//    func testThatDateWhenTheUserWasRecentlyActiveIsStored() {
//        let application = UIApplicationTypeMock(applicationState: .active)
//        libraryUpdateApplicationService.applicationDidBecomeActive(application)
//        let date: Date? = storage.get(for: .mostRecentUserTriggeredAppLaunchDate)
//        XCTAssertNotNil(date)
//    }
//
//    func testThatOldLibraryIsDeletedAfterANewLibraryIsInstalled() {
//        let oldLibraryUrl = libraryRepository.library.url
//        let libraryUpdateToDownload = LibraryUpdate.fixture()
//        learningCardClient.checkForLibraryUpdateHandler = { _, completion in
//            completion(.success(libraryUpdateToDownload))
//        }
//        learningCardClient.downloadFileHandler = { _, _, _ in
//            let destinationFolder = self.tempWorkingFolder.appendingPathComponent("testThatOldLibraryIsDeletedAfterANewLibraryIsInstalled")
//            try! FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
//            let testArchive = try! Library.Fixture.validArchive()
//            let destinationFile = destinationFolder.appendingPathComponent(UUID().uuidString)
//            try! FileManager.default.moveItem(at: testArchive, to: destinationFile)
//            self.libraryUpdateApplicationService.downloadClientDidFinish(source: libraryUpdateToDownload.url, destination: destinationFile)
//        }
//
//        let expectation = self.expectation(description: "Library Update was Installed")
//        let observer = NotificationCenter.default.observe(for: LibraryUpdaterStateDidChangeNotification.self, object: nil, queue: nil) { notification in
//            if case .upToDate = notification.newValue {
//                expectation.fulfill()
//            }
//        }
//        _ = observer
//        // Run the actal test
//        XCTAssert(FileManager.default.fileExists(atPath: oldLibraryUrl.path))
//        // Running this on a background thread cause LibraryUpdateApplicationService.performInstallation
//        // asserts when called on the main thread ...
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.libraryUpdateApplicationService.initiateUpdate(isUserTriggered: true)
//        }
//        wait(for: [expectation], timeout: 4.0)
//        XCTAssertFalse(FileManager.default.fileExists(atPath: oldLibraryUrl.path))
//    }
//
//    func testThatOldLibraryIsNotDeletedAfterInstallationFails() {
//        let oldLibraryUrl = libraryRepository.library.url
//        let libraryUpdateToDownload = LibraryUpdate.fixture()
//        learningCardClient.checkForLibraryUpdateHandler = { _, completion in
//            completion(.success(libraryUpdateToDownload))
//        }
//        learningCardClient.downloadFileHandler = { _, _, _ in
//            let destinationFolder = self.tempWorkingFolder.appendingPathComponent("testThatOldLibraryIsNotDeletedAfterInstallationFails")
//            try! FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
//            let testArchive = try! Library.Fixture.invalidArchive()
//            let destinationFile = destinationFolder.appendingPathComponent(UUID().uuidString)
//            try! FileManager.default.moveItem(at: testArchive, to: destinationFile)
//            self.libraryUpdateApplicationService.downloadClientDidFinish(source: libraryUpdateToDownload.url, destination: destinationFile)
//        }
//
//        let expectation = self.expectation(description: "Library Update was Installed")
//        let observer = NotificationCenter.default.observe(for: LibraryUpdaterStateDidChangeNotification.self, object: nil, queue: nil) { notification in
//            if case .failed = notification.newValue {
//                expectation.fulfill()
//            }
//        }
//        _ = observer
//
//        // Run the actal test
//        XCTAssert(FileManager.default.fileExists(atPath: oldLibraryUrl.path))
//        // Running this on a background thread cause LibraryUpdateApplicationService.performInstallation
//        // asserts when called on the main thread ...
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.libraryUpdateApplicationService.initiateUpdate(isUserTriggered: true)
//        }
//        wait(for: [expectation], timeout: 4.0)
//        XCTAssert(FileManager.default.fileExists(atPath: oldLibraryUrl.path))
//    }
//
//    func testThatTheLibraryZipFileIsDeletedOnceTheLibraryIsInstalled() {
//        let libraryUpdateToDownload = LibraryUpdate.fixture()
//        learningCardClient.checkForLibraryUpdateHandler = { _, completion in
//            completion(.success(libraryUpdateToDownload))
//        }
//        let destinationFolder = self.tempWorkingFolder.appendingPathComponent("testThatTheLibraryZipFileIsDeletedOnceTheLibraryIsInstalled")
//        let testArchive = try! Library.Fixture.validArchive()
//        let destinationFile = destinationFolder.appendingPathComponent(UUID().uuidString)
//        learningCardClient.downloadFileHandler = { _, _, _ in
//            try! FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
//            try! FileManager.default.moveItem(at: testArchive, to: destinationFile)
//            self.libraryUpdateApplicationService.downloadClientDidFinish(source: libraryUpdateToDownload.url, destination: destinationFile)
//        }
//
//        let expectation = self.expectation(description: "Library Update was Installed")
//        let observer = NotificationCenter.default.observe(for: LibraryUpdaterStateDidChangeNotification.self, object: nil, queue: nil) { notification in
//            if case .upToDate = notification.newValue {
//                expectation.fulfill()
//            }
//        }
//        _ = observer
//
//        // Run the actal test
//        // Running this on a background thread cause LibraryUpdateApplicationService.performInstallation
//        // asserts when called on the main thread ...
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.libraryUpdateApplicationService.initiateUpdate(isUserTriggered: true)
//        }
//        wait(for: [expectation], timeout: 4.0)
//        XCTAssertFalse(FileManager.default.fileExists(atPath: destinationFile.path))
//    }
//
//    func testThatTheLibraryZipFileIsDeletedIfTheLibraryInstallationFails() {
//        let libraryUpdateToDownload = LibraryUpdate.fixture()
//        learningCardClient.checkForLibraryUpdateHandler = { _, completion in
//            completion(.success(libraryUpdateToDownload))
//        }
//        let destinationFolder = self.tempWorkingFolder.appendingPathComponent("testThatTheLibraryZipFileIsDeletedOnceTheLibraryIsInstalled")
//        let testArchive = try! Library.Fixture.invalidArchive()
//        let destinationFile = destinationFolder.appendingPathComponent(UUID().uuidString)
//        learningCardClient.downloadFileHandler = { _, _, _ in
//            try! FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
//            try! FileManager.default.moveItem(at: testArchive, to: destinationFile)
//            self.libraryUpdateApplicationService.downloadClientDidFinish(source: libraryUpdateToDownload.url, destination: destinationFile)
//        }
//
//        let expectation = self.expectation(description: "Library Update was Installed")
//        let observer = NotificationCenter.default.observe(for: LibraryUpdaterStateDidChangeNotification.self, object: nil, queue: nil) { notification in
//            if case .failed = notification.newValue {
//                expectation.fulfill()
//            }
//        }
//        _ = observer
//
//        // Run the actal test
//        // Running this on a background thread cause LibraryUpdateApplicationService.performInstallation
//        // asserts when called on the main thread ...
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.libraryUpdateApplicationService.initiateUpdate(isUserTriggered: true)
//        }
//        wait(for: [expectation], timeout: 4.0)
//        XCTAssertFalse(FileManager.default.fileExists(atPath: destinationFile.path))
//    }
//
//    func testThatTheCleanerIsCalledAtInstantiationTime() throws {
//        let cleanerMock = LibraryUpdaterLegacyCleanerTypeMock()
//        let expectation = self.expectation(description: "The Cleaner was called")
//        cleanerMock.cleanupHandler = {
//            expectation.fulfill()
//        }
//
//        _ = LibraryUpdateApplicationService(
//            learningCardClient: learningCardClient,
//            storage: MemoryStorage(),
//            libraryRepository: libraryRepository,
//            accessRepository: accessRepository,
//            cleaner: cleanerMock)
//
//        wait(for: [expectation], timeout: 0.5)
//    }
//}
