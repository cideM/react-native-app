//
//  WelcomePresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 25.01.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class WelcomePresenterTests: XCTestCase {

    var coordinator: AuthenticationCoordinatorTypeMock!
    var consentApplicationService: ConsentApplicationServiceTypeMock!
    var trackingProvider: TrackingTypeMock!
    var presenter: WelcomePresenter!

    override func setUp() {
        coordinator = AuthenticationCoordinatorTypeMock()
        consentApplicationService = ConsentApplicationServiceTypeMock()
        trackingProvider = TrackingTypeMock()

        presenter = WelcomePresenter(authenticationCoordinator: coordinator, consentApplicationService: consentApplicationService, trackingProvider: trackingProvider)
    }

    func testThatSettingTheViewOnThePresenterAsksConsentServiceToShowCosentDialogIfNeeded() {
        XCTAssertEqual(consentApplicationService.showConsentDialogIfNeededCallCount, 0)
        presenter.viewDidAppear()
        XCTAssertEqual(consentApplicationService.showConsentDialogIfNeededCallCount, 1)
    }

    func testThatSettingTheViewOnThePresenterTriggersTheRightTrackingEvent() {
        let expectation = self.expectation(description: "analytics tracking provider was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .signupAndLogin(let loginAndSignupEvent):
                switch loginAndSignupEvent {
                case .welcomeScreenShown: expectation.fulfill()
                default: XCTFail("Unexpected event")
                }
            default: XCTFail("Unexpected event")
            }
        }

        presenter.viewDidAppear()
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingSignupButtonCallsGoToUserStageSelectionOnTheCoordinator() {
        XCTAssertEqual(coordinator.goToUserStageSelectionCallCount, 0)

        presenter.signupButtonTapped()

        XCTAssertEqual(coordinator.goToUserStageSelectionCallCount, 1)
    }

    func testThatTappingOnSignupButtonTriggersTheRightTrackingEvent() {
        let expectation = self.expectation(description: "analytics tracking provider was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .signupAndLogin(let loginAndSignupEvent):
                switch loginAndSignupEvent {
                case .signUpButtonClicked: expectation.fulfill()
                default: XCTFail("Unexpected event")
                }
            default: XCTFail("Unexpected event")
            }
        }

        presenter.signupButtonTapped()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingLoginButtonCallsGoToLoginOnTheCoordinator() {
        XCTAssertEqual(coordinator.goToLoginCallCount, 0)

        presenter.loginButtonTapped()

        XCTAssertEqual(coordinator.goToLoginCallCount, 1)
    }

    func testThatTappingOnLoginButtonTriggersTheRightTrackingEvent() {
        let expectation = self.expectation(description: "analytics tracking provider was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .signupAndLogin(let loginAndSignupEvent):
                switch loginAndSignupEvent {
                case .loginButtonClicked: expectation.fulfill()
                default: XCTFail("Unexpected event")
                }
            default: XCTFail("Unexpected event")
            }
        }

        presenter.loginButtonTapped()

        wait(for: [expectation], timeout: 0.1)
    }
}
