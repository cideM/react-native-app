//
//  PharmaPresenterOfflineOptInDialogTests.swift
//  KnowledgeTests
//
//  Created by Roberto Seidenberg on 15.06.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class PharmaPresenterOptInDialogTests: XCTestCase {

    private var view: PharmaViewTypeMock!
    private var pharmaService: PharmaDatabaseApplicationServiceTypeMock!
    private var pharmaRepository: PharmaRepositoryTypeMock!
    private var trackingProvider: TrackingTypeMock!

    override func setUp() {
        view = PharmaViewTypeMock()
        pharmaService = PharmaDatabaseApplicationServiceTypeMock()
        pharmaRepository = PharmaRepositoryTypeMock()
        trackingProvider = TrackingTypeMock()
    }

    func testShouldPresentDialogIfAllRequirementsAreFulfilled() {
        pharmaService.pharmaDatabase = nil
        pharmaRepository.shouldShowPharmaOfflineDialog = true
        pharmaRepository.pharmaDialogWasDisplayedDate = Date.distantPast
        pharmaRepository.pharmaResultWasDisplayedCount = Int.random(in: 5...500) // min 5 to trigger display

        PharmaOfflineOptInDialog.presentIfRequired(above: view, using: pharmaService, and: pharmaRepository)
        XCTAssertEqual(view.presentMessageCallCount, 1)
    }

    func testShouldNotPresentDialogIfADatabaseIsAlreadyInstalled() {

        // Theses values prevent display ...
        pharmaService.pharmaDatabase = PharmaDatabaseTypeMock()

        // All these values do trigger the display ...
        pharmaRepository.shouldShowPharmaOfflineDialog = true
        pharmaRepository.pharmaDialogWasDisplayedDate = Date.distantPast
        pharmaRepository.pharmaResultWasDisplayedCount = 20 // min 5 to trigger display

        PharmaOfflineOptInDialog.presentIfRequired(above: view, using: pharmaService, and: pharmaRepository)
        XCTAssertEqual(view.presentMessageCallCount, 0)
    }

    func testShouldNotPresentDialogIfItHasBeenDisabledByTheUser() {

        // Theses values prevent display ...
        pharmaRepository.shouldShowPharmaOfflineDialog = false

        // All these values do trigger the display ...
        pharmaService.pharmaDatabase = nil
        pharmaRepository.pharmaDialogWasDisplayedDate = Date.distantPast
        pharmaRepository.pharmaResultWasDisplayedCount = 20 // min 5 to trigger display

        PharmaOfflineOptInDialog.presentIfRequired(above: view, using: pharmaService, and: pharmaRepository)
        XCTAssertEqual(view.presentMessageCallCount, 0)
    }

    func testShouldNotPresentDialogIfItHasBeenDisabledDuringTheLastDay() {

        // Theses values prevent display ...
        pharmaRepository.pharmaDialogWasDisplayedDate = Date()

        // All these values do trigger the display ...
        pharmaService.pharmaDatabase = nil
        pharmaRepository.shouldShowPharmaOfflineDialog = true
        pharmaRepository.pharmaResultWasDisplayedCount = 20 // min 5 to trigger display

        PharmaOfflineOptInDialog.presentIfRequired(above: view, using: pharmaService, and: pharmaRepository)
        XCTAssertEqual(view.presentMessageCallCount, 0)
    }

    func testShouldNotPresentDialogIfItThePharmaScreenHasNotBeenDisplayedOftenEnough() {

        // Theses values prevent display ...
        pharmaRepository.pharmaResultWasDisplayedCount = 2 // min 5 to trigger display

        // All these values do trigger the display ...
        pharmaService.pharmaDatabase = nil
        pharmaRepository.shouldShowPharmaOfflineDialog = true
        pharmaRepository.pharmaDialogWasDisplayedDate = Date.distantPast

        PharmaOfflineOptInDialog.presentIfRequired(above: view, using: pharmaService, and: pharmaRepository)
        XCTAssertEqual(view.presentMessageCallCount, 0)
    }
}
