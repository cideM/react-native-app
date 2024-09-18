//
//  AdjustAttributionTrackingApplicationServiceTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 05.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class AdjustAttributionTrackingApplicationServiceTests: XCTestCase {
    var configuration: ConfigurationMock!
    var adjustService: AdjustAttributionTrackingApplicationService!
    var storage: Storage!

    override func setUp() {
        storage = MemoryStorage()
        configuration = ConfigurationMock()
        adjustService = AdjustAttributionTrackingApplicationService(
            adjust: AdjustTypeMock.self,
            segmentTracker: SegmentTrackerTypeMock(),
            configuration: configuration,
            storage: storage)
    }

    func testThatAdjustServiceIsEnabledIfAdjustIsEnabled() {
        AdjustTypeMock.isEnabledHandler = {
            true
        }

        XCTAssertTrue(adjustService.isEnabled)
    }

    func testThatAdjustServiceIsDisabledIfAdjustIsDisabled() {
        AdjustTypeMock.isEnabledHandler = {
            false
        }

        XCTAssertFalse(adjustService.isEnabled)
    }

    func testThatAdjustIsCalledToSetDisabledOnAppLaunch() {
        let expectation = self.expectation(description: "app did launch was called")
        AdjustTypeMock.setEnabledHandler = { enabled in
            XCTAssertFalse(enabled)
            expectation.fulfill()
        }

        _ = adjustService.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatAdjustAppDidLaunchIsCalledOnAppLaunch() {
        XCTAssertEqual(AdjustTypeMock.appDidLaunchCallCount, 0)

        _ = adjustService.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)

        XCTAssertEqual(AdjustTypeMock.appDidLaunchCallCount, 1)
    }

    func testThatAdjustIsEnabledIf_ConsentGotChanged_AndUserGaveConsent_AndApprovedAppTracking_IfConfigurationHasAdjustEnabled() {
        let expectation = self.expectation(description: "set enabled was called")
        AdjustTypeMock.requestTrackingAuthorizationHandler = { completion in
            completion?(3)
        }
        AdjustTypeMock.setEnabledHandler = { enabled in
            XCTAssertTrue(enabled)
            expectation.fulfill()
        }

        adjustService.consentDidChange([.adjust: true])

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatAdjustIsEnabledIf_ConsentGotChanged_AndUserGaveConsent_ButDidNotApproveAppTracking_IfConfigurationHasAdjustEnabled() {
        let expectation = self.expectation(description: "set enabled was called")
        AdjustTypeMock.requestTrackingAuthorizationHandler = { completion in
            completion?(UInt.random(in: 0...2))
        }
        AdjustTypeMock.setEnabledHandler = { enabled in
            XCTAssertTrue(enabled)
            expectation.fulfill()
        }

        adjustService.consentDidChange([.adjust: true])

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatAdjustIsDisabledIf_ConsentGotChanged_AndUserDidNotGiveConsent_NoMatterWhatTheStatusOfAppTrackingIs_IfConfigurationHasAdjustEnabled() {
        let expectation = self.expectation(description: "set enabled was called")
        AdjustTypeMock.requestTrackingAuthorizationHandler = { completion in
            completion?(UInt.random(in: 0...3))
        }
        AdjustTypeMock.setEnabledHandler = { enabled in
            XCTAssertFalse(enabled)
            expectation.fulfill()
        }

        adjustService.consentDidChange([.adjust: false])

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatAdjustIsDisabledIf_ConsentGotChanged_AndNoAdjustServiceConfigurationWasPassed_NoMatterWhatTheStatusOfAppTrackingIs_IfConfigurationHasAdjustEnabled() {
        let expectation = self.expectation(description: "set enabled was called")
        AdjustTypeMock.requestTrackingAuthorizationHandler = { completion in
            completion?(UInt.random(in: 0...3))
        }
        AdjustTypeMock.setEnabledHandler = { enabled in
            XCTAssertFalse(enabled)
            expectation.fulfill()
        }

        adjustService.consentDidChange([:])

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatAdjustSettingsAreRemoved_WhenResetWasCalled() {

        AdjustTypeMock.setEnabledHandler = { enabled in
            // Does not do anything but must be here otherwise test cancels without result
        }

        storage.store(true, for: .userGaveAdjustConsent)
        adjustService.reset()
        let isEnabled: Bool = storage.get(for: .userGaveAdjustConsent) ?? false
        XCTAssertEqual(isEnabled, false)
    }
}
