//
//  BrazeValueMappingTests.swift
//  UnitTests
//
//  Created by Elmar Tampe on 23.06.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import XCTest
@testable import Domain
@testable import Knowledge_DE

final class BrazeTrackingPropertyMappingTests: XCTestCase {

    func testRegioTrackingPropertyDE() {
        XCTAssertEqual(BrazeRegion.de.trackingProperty(), "eu")
    }

    func testRegioTrackingPropertyUS() {
        XCTAssertEqual(BrazeRegion.us.trackingProperty(), "us")
    }

    func testTrackingPropertyForEducationStatus() {
        XCTAssertEqual(BrazeStage.preclinic.trackingProperty(), 1)
        XCTAssertEqual(BrazeStage.clinic.trackingProperty(), 2)
        XCTAssertEqual(BrazeStage.physician.trackingProperty(), 4)
    }

    func testUserStageToEducationStatusMapping() {
        XCTAssertEqual(BrazeApplicationService.map(userStage: Tracker.Event.SignupAndLogin.UserStage.physician), BrazeStage.physician)
        XCTAssertEqual(BrazeApplicationService.map(userStage: Tracker.Event.SignupAndLogin.UserStage.clinic), BrazeStage.clinic)
        XCTAssertEqual(BrazeApplicationService.map(userStage: Tracker.Event.SignupAndLogin.UserStage.preclinic), BrazeStage.preclinic)
    }

    func testAppCodeRegionCodeMapping() {
        XCTAssertEqual(BrazeApplicationService.map(variant: .knowledge), BrazeRegion.us)
        XCTAssertEqual(BrazeApplicationService.map(variant: .wissen), BrazeRegion.de)
    }
}
