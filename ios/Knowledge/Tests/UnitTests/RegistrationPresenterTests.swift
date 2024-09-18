//
//  RegistrationPresenterTests.swift
//  KnowledgeTests
//
//  Created by Merve Kavaklioglu on 16.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import Networking
import XCTest

class RegistrationPresenterTests: XCTestCase {

    var presenter: RegistrationPresenter!

    var view: RegistrationViewTypeMock!
    var coordinator: AuthenticationCoordinatorTypeMock!
    var authenticationClient: AuthenticationClientMock!
    var authorizationRepository: AuthorizationRepositoryTypeMock!
    var registrationRepository: RegistrationRepositoryTypeMock!
    var appConfiguration: ConfigurationMock!
    var userDefaultsStorage: Storage!
    var trackingProvider: TrackingTypeMock!
    var brazeClient: BrazeApplicationServiceTypeMock!

    override func setUp() {
        authenticationClient = AuthenticationClientMock()
        view = RegistrationViewTypeMock()
        trackingProvider = TrackingTypeMock()
        authorizationRepository = AuthorizationRepositoryTypeMock()
        registrationRepository = RegistrationRepositoryTypeMock()
        appConfiguration = ConfigurationMock(appVariant: .fixture())
        userDefaultsStorage = MemoryStorage()
        coordinator = AuthenticationCoordinatorTypeMock()
        brazeClient = BrazeApplicationServiceTypeMock()

        presenter = RegistrationPresenter(coordinator: coordinator,
                                          authenticationClient: authenticationClient,
                                          authorizationRepository: authorizationRepository,
                                          registrationRepository: registrationRepository,
                                          appConfiguration: appConfiguration,
                                          userDefaultsStorage: userDefaultsStorage,
                                          analyticsTracking: trackingProvider,
                                          brazeClient: brazeClient, 
                                          remoteConfigRepository: RemoteConfigRepositoryTypeMock())
        presenter.view = view
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenEmailTextFieldRightButtonTapped() {
        let exp = expectation(description: "trackingProvider was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .signupAndLogin(let event):
                switch event {
                case .clearEmail:
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        presenter.emailTextFieldRightButtonTapped()
        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenPasswordTextFieldRightButtonTapped() {
        let exp = expectation(description: "trackingProvider was called")
        presenter.passwordTextFieldRightButtonTapped(isVisible: true)

        trackingProvider.trackHandler = { event in
            switch event {
            case .signupAndLogin(let event):
                switch event {
                case .togglePasswordVisiblity(_, let status):
                    XCTAssertEqual(status, .invisible)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        presenter.passwordTextFieldRightButtonTapped(isVisible: false)
        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenNavigateToFunctionIsCalledThenGoToLoginFunctionIsCalled () {
        // Given
        XCTAssertEqual(coordinator.goToLoginCallCount, 0)

        // When
        presenter.navigateToLogin(email: .fixture(), password: .fixture())

        // Then
        XCTAssertEqual(coordinator.goToLoginCallCount, 1)
    }

    func testThatWhenRegisterSucceededsLoginIsCalled() {
        registrationRepository.userStage = .fixture()
        let expectation = self.expectation(description: "Login was called")

        authenticationClient.signupHandler = { [weak self] _, _, _, _, _, _, _, _, completion in
            completion(.success(()))
            XCTAssertEqual(self?.authenticationClient.loginCallCount, 1)
            expectation.fulfill()
        }

        presenter.startButtonTapped(with: "email@email.com", password: .fixture())
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenRegisterFailedLoginIsNotCalled() {
        registrationRepository.userStage = .fixture()
        let expectation = self.expectation(description: "Login was not called")
        let emailTest = "email@email.com"
        let passwordTest = "12345678"

        authenticationClient.signupHandler = { [weak self] _, _, _, _, _, _, _, _, completion in
            completion(.failure(.noInternetConnection))
            XCTAssertEqual(self?.authenticationClient.loginCallCount, 0)
            expectation.fulfill()
        }
        presenter.startButtonTapped(with: emailTest, password: passwordTest)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenRegisterFailedWithEmailAlreadyRegisteredError() {
        registrationRepository.userStage = .fixture()
        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 3

        let emailTest = "email@email.com"
        let passwordTest = "12345678"

        authenticationClient.signupHandler = { _, _, _, _, _, _, _, _, completion in
            completion(.failure(.apiResponseError([.emailAlreadyRegistered])))
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .signupAndLogin(let event):
                switch event {
                case .signUpEmailAlreadyTaken(let email):
                    XCTAssertEqual(email, emailTest)
                    exp.fulfill()
                case .emailSubmitted(let email):
                    XCTAssertEqual(email, emailTest)
                    exp.fulfill()
                case .passwordSubmitted(let email):
                    XCTAssertEqual(email, emailTest)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        presenter.startButtonTapped(with: emailTest, password: passwordTest)
        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenLoginFailedGoToLoginIsCalled() {
        registrationRepository.userStage = .fixture()
        let expectation = self.expectation(description: "goToLogin was called")
        let emailTest = "email@email.com"
        let passwordTest = "12345678"

        XCTAssertEqual(coordinator.goToLoginCallCount, 0)

        authenticationClient.signupHandler = { _, _, _, _, _, _, _, _, completion in
            completion(.success(()))
        }

        authenticationClient.loginHandler = { [weak self] _, _, _, completion in
            completion(.failure(.noInternetConnection))
            XCTAssertEqual(self?.coordinator.goToLoginCallCount, 1)
            expectation.fulfill()
        }

        presenter.startButtonTapped(with: emailTest, password: passwordTest)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenLoginSucceededGoToNextIsCalled() {
        registrationRepository.userStage = .fixture()
        let expectation = self.expectation(description: "goToNext was called")
        let emailTest = "email@email.com"
        let passwordTest = "12345678"

        XCTAssertEqual(coordinator.finishCallCount, 0)

        authenticationClient.signupHandler = { _, _, _, _, _, _, _, _, completion in
            completion(.success(()))
        }

        authenticationClient.loginHandler = { [weak self] _, _, _, completion in
            completion(.success(.fixture()))
            XCTAssertEqual(self?.coordinator.finishCallCount, 1)
            expectation.fulfill()
        }

        presenter.startButtonTapped(with: emailTest, password: passwordTest)
        wait(for: [expectation], timeout: 0.1)
    }
}
