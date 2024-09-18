//
//  LoginPresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 27.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import Networking
import XCTest

class LoginPresenterTests: XCTestCase {

    var presenter: LoginPresenter!

    var view: LoginViewTypeMock!
    var coordinator: AuthenticationCoordinatorTypeMock!
    var authenticationClient: AuthenticationClientMock!
    var authorizationRepository: AuthorizationRepositoryTypeMock!
    var userDefaultsStorage: MemoryStorage!
    var appConfiguration: ConfigurationMock!
    var trackingProvider: TrackingTypeMock!

    override func setUp() {
        authenticationClient = AuthenticationClientMock()
        view = LoginViewTypeMock()
        trackingProvider = TrackingTypeMock()
        authorizationRepository = AuthorizationRepositoryTypeMock()
        appConfiguration = ConfigurationMock()
        userDefaultsStorage = MemoryStorage()
        coordinator = AuthenticationCoordinatorTypeMock()

        presenter = LoginPresenter(coordinator: coordinator,
                                   authenticationClient: authenticationClient,
                                   authorizationRepository: authorizationRepository,
                                   userDefaultsStorage: userDefaultsStorage,
                                   configuration: appConfiguration,
                                   trackingProvider: trackingProvider,
                                   prefilledCredentials: nil)
        presenter.view = view
    }

    func testThatValidateCredentialsDoesNotEnableTheLoginButtonWhenBothEmailAndPasswordAreInalid() {
        let invalidEmail = "i"
        let invalidPassword = ""
        let expectation = self.expectation(description: "setLoginButtonIsEnabled was called")
        view.setLoginButtonIsEnabledHandler = { isEnabled in
            XCTAssertFalse(isEnabled)
            expectation.fulfill()
        }

        presenter.validateCredentials(email: invalidEmail, password: invalidPassword)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatValidateCredentialsDoesNotEnableTheLoginButtonWhenTheEmailIsInvalidButPasswordIsValid() {
        let invalidEmail = "i"
        let validPassword = "1"
        let expectation = self.expectation(description: "setLoginButtonIsEnabled was called")
        view.setLoginButtonIsEnabledHandler = { isEnabled in
            XCTAssertFalse(isEnabled)
            expectation.fulfill()
        }

        presenter.validateCredentials(email: invalidEmail, password: validPassword)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatValidateCredentialsDoesNotEnableTheLoginButtonWhenTheEmailIsValidButPasswordIsInvalid() {
        let validEmail = "val"
        let invalidPassword = ""
        let expectation = self.expectation(description: "setLoginButtonIsEnabled was called")
        view.setLoginButtonIsEnabledHandler = { isEnabled in
            XCTAssertFalse(isEnabled)
            expectation.fulfill()
        }

        presenter.validateCredentials(email: validEmail, password: invalidPassword)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatValidateCredentialsEnablesTheLoginButtonWhenBothEmailAndPasswordAreValid() {
        let validEmail = "val"
        let validPassword = "1"
        let expectation = self.expectation(description: "setLoginButtonIsEnabled was called")
        view.setLoginButtonIsEnabledHandler = { isEnabled in
            XCTAssertTrue(isEnabled)
            expectation.fulfill()
        }

        presenter.validateCredentials(email: validEmail, password: validPassword)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingClearButtonSendsTheRightTrackingEvent() {
        let expectation = self.expectation(description: "trackingProvider track was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .signupAndLogin(let event):
                switch event {
                case .clearEmail(let locatedOn):
                    XCTAssertEqual(locatedOn, .login)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }

        presenter.didTapClearButton()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingTogglePasswordSendsTheRightTrackingEvent() {
        let isVisible: Bool = .fixture()
        let expectation = self.expectation(description: "trackingProvider track was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .signupAndLogin(let event):
                switch event {
                case .togglePasswordVisiblity(let locatedOn, let status):
                    XCTAssertEqual(locatedOn, .login)
                    XCTAssertEqual(status == .invisible, isVisible)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }

        presenter.didTapPasswordToggleButton(isvisible: isVisible)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingLoginButtonSendsTheRightTrackingEvent() {
        let email: String = .fixture()
        let expectation = self.expectation(description: "trackingProvider track was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .signupAndLogin(let event):
                switch event {
                case .loginInitiated(let trackedEmail):
                    XCTAssertEqual(email, trackedEmail)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }

        presenter.didTapLoginButton(email: email, password: .fixture())

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingLoginButtonCallsTheClientWithTheRightParameters() {
        let emailToSend: String = .fixture()
        let passwordToSend: String = .fixture()
        authorizationRepository.deviceId = .fixture()

        let expectation = self.expectation(description: "authenticationClient login called")
        authenticationClient.loginHandler = { email, password, deviceId, _ in
            XCTAssertEqual(emailToSend, email)
            XCTAssertEqual(passwordToSend, password)
            XCTAssertEqual(self.authorizationRepository.deviceId, deviceId)

            expectation.fulfill()
        }

        presenter.didTapLoginButton(email: emailToSend, password: passwordToSend)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTheCoordinatorIsAskedToGotoNextScreenAfterSuccessfulLogin() {
        let expectation = self.expectation(description: "authenticationClient login called")
        authenticationClient.loginHandler = { _, _, _, completion in
            completion(.success(.fixture()))
            expectation.fulfill()
        }
        XCTAssertEqual(coordinator.finishCallCount, 0)

        presenter.didTapLoginButton(email: .fixture(), password: .fixture())

        XCTAssertEqual(coordinator.finishCallCount, 1)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTheViewIsAskedToPresentAnErrorAfterFailingLogin() {
        let expectation = self.expectation(description: "authenticationClient login called")
        authenticationClient.loginHandler = { _, _, _, completion in
            completion(.failure(.apiResponseError([.other(.fixture())])))
            expectation.fulfill()
        }
        XCTAssertEqual(view.presentMessageCallCount, 0)

        presenter.didTapLoginButton(email: .fixture(), password: .fixture())

        XCTAssertEqual(view.presentMessageCallCount, 1)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatFirstLoginIsTrackedAfterFirstLoginIsCompleted() {
        let emailToSend: String = .fixture()
        let firstLoginWasTracked: Bool? = nil
        userDefaultsStorage.store(firstLoginWasTracked, for: .firstLoginWasTracked)
        let expectation = self.expectation(description: "authenticationClient login called")
        authenticationClient.loginHandler = { _, _, _, completion in
            completion(.success(.fixture()))
            expectation.fulfill()
        }
        let trackingExpectation = self.expectation(description: "trackingProvider track was called")
        trackingExpectation.expectedFulfillmentCount = 2
        trackingProvider.trackHandler = { event in
            switch event {
            case .signupAndLogin(let event):
                switch event {
                case .loginInitiated(email: let email):
                    XCTAssertEqual(emailToSend, email)
                    trackingExpectation.fulfill()
                case .loginCompleted:
                    XCTFail("Unexpected event")
                case .firstLoginCompleted(let email):
                    XCTAssertEqual(emailToSend, email)
                    trackingExpectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }

        presenter.didTapLoginButton(email: emailToSend, password: .fixture())

        wait(for: [expectation, trackingExpectation], timeout: 0.1)
    }

    func testThatFirstLoginIsNotTrackedAfterLoginIsCompletedIfItWasNotTheFirstLogin() {
        let emailToSend: String = .fixture()
        let firstLoginWasTracked = true
        userDefaultsStorage.store(firstLoginWasTracked, for: .firstLoginWasTracked)
        let expectation = self.expectation(description: "authenticationClient login called")
        authenticationClient.loginHandler = { _, _, _, completion in
            completion(.success(.fixture()))
            expectation.fulfill()
        }
        let trackingExpectation = self.expectation(description: "trackingProvider track was called")
        trackingExpectation.expectedFulfillmentCount = 2
        trackingProvider.trackHandler = { event in
            switch event {
            case .signupAndLogin(let event):
                switch event {
                case .loginInitiated(email: let email):
                    XCTAssertEqual(emailToSend, email)
                    trackingExpectation.fulfill()
                case .loginCompleted(let email):
                    XCTAssertEqual(emailToSend, email)
                    trackingExpectation.fulfill()
                case .firstLoginCompleted:
                    XCTFail("Unexpected event")
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }

        presenter.didTapLoginButton(email: emailToSend, password: .fixture())

        wait(for: [expectation, trackingExpectation], timeout: 0.1)
    }

    func testThatInitializingThePresenterWithPrefillCredentialsPassesThemToTheView() {
        let credentials: (String?, String?) = (.fixture(), .fixture())
        let presenter = LoginPresenter(coordinator: coordinator,
                                       authenticationClient: authenticationClient,
                                       authorizationRepository: authorizationRepository,
                                       userDefaultsStorage: userDefaultsStorage,
                                       configuration: appConfiguration,
                                       trackingProvider: trackingProvider,
                                       prefilledCredentials: credentials)
        let expectation = self.expectation(description: "Prefill was called")
        view.prefillHandler = { email, password in
            XCTAssertEqual(credentials.0, email)
            XCTAssertEqual(credentials.1, password)
            expectation.fulfill()
        }
        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }
}
