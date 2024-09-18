//
//  AccountSettingsPresenterTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 14.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

import Foundation
import Domain
import Networking

class AccountSettingsPresenterTests: XCTestCase {
    var coordinator: SettingsCoordinatorTypeMock!
    var learningCardClient: LearningCardLibraryClientMock!
    var authenticationClient: AuthenticationClientMock!
    var authorizationRepository: AuthorizationRepositoryTypeMock!
    var trackingProvider: TrackingTypeMock!
    var view: AccountSettingsViewTypeMock!
    var presenter: AccountSettingsPresenter!

    override func setUp() {
        coordinator = SettingsCoordinatorTypeMock()
        learningCardClient = LearningCardLibraryClientMock()
        authenticationClient = AuthenticationClientMock()
        authorizationRepository = AuthorizationRepositoryTypeMock()
        trackingProvider = TrackingTypeMock()
        view = AccountSettingsViewTypeMock()

        presenter = AccountSettingsPresenter(
            coordinator: coordinator,
            authorizationRepository: authorizationRepository,
            learningCardClient: learningCardClient,
            authenticationClient: authenticationClient,
            trackingProvider: trackingProvider)
        presenter.view = view
    }

    func testThatEmailIsSetOnViewWhenTheViewIsSetOnThePresenter() {
        let authorizationUserEmail = String.fixture()
        authorizationRepository.authorization = Authorization(token: .fixture(), user: .fixture(email: authorizationUserEmail))
        let expectation = self.expectation(description: "set email was called")
        view.setEmailHandler = { email in
            XCTAssertEqual(email, authorizationUserEmail)
            expectation.fulfill()
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenTheViewIsSetOnThePresenter() {
        let authorizationUserEmail = String.fixture()
        authorizationRepository.authorization = Authorization(token: .fixture(), user: .fixture(email: authorizationUserEmail))
        let expectation = self.expectation(description: "trackingProvider was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .settings(let event):
            switch event {
            case .settingsAccountOpened:
                expectation.fulfill()
            default:
                XCTFail()
            }
            default:
                XCTFail()
            }
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTheRightDeviceIDIsPassedToLogoutFunctionOnTheClientOnLogOut() {
        let expectation = self.expectation(description: "client was called")

        authorizationRepository.deviceId = .fixture()

        authenticationClient.logoutHandler = { deviceToken, _ in
            XCTAssertEqual(deviceToken, self.authorizationRepository.deviceId)
            expectation.fulfill()
        }

        view.presentMessageHandler = { _, _, actions in
            actions[1].execute()
        }

        presenter.logoutButtonTapped()
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatLogoutFunctionOnTheClientIsCalledWhenTheUserLogsOut() {
        let expectation = self.expectation(description: "client was called")

        authenticationClient.logoutHandler = { _, _ in
            expectation.fulfill()
        }

        view.presentMessageHandler = { _, _, actions in
            actions[1].execute()
        }

        presenter.logoutButtonTapped()
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenLogoutIsTapped() {
        let expectation = self.expectation(description: "trackingProvider was called")

        trackingProvider.trackHandler = { event in
            switch event {
            case .settings(let event):
            switch event {
            case .settingsLogoutClicked:
                expectation.fulfill()
            default:
                XCTFail()
            }
            default:
                XCTFail()
            }
        }

        presenter.logoutButtonTapped()
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTheViewIsAskedToShowAMessageWhenLogoutIsTapped() {
        XCTAssertEqual(view.presentMessageCallCount, 0)

        presenter.logoutButtonTapped()

        XCTAssertEqual(view.presentMessageCallCount, 1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenCancelIsTapped() {
        let expectation = self.expectation(description: "view presentMessage was called")
        expectation.expectedFulfillmentCount = 2

        trackingProvider.trackHandler = { event in
            switch event {
            case .settings(let event):
            switch event {
            case .settingsLogoutClicked:
                expectation.fulfill()
            case .settingsLogoutCancelled:
                expectation.fulfill()
            default:
                XCTFail()
            }
            default:
                XCTFail()
            }
        }

        view.presentMessageHandler = { _, _, actions in
            actions[0].execute()
        }

        presenter.logoutButtonTapped()
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenConfirmIsTapped() {
        let expectation = self.expectation(description: "view presentMessage was called")
        expectation.expectedFulfillmentCount = 2

        trackingProvider.trackHandler = { event in
            switch event {
            case .settings(let event):
            switch event {
            case .settingsLogoutClicked:
                expectation.fulfill()
            case .settingsLogoutConfirmed:
                expectation.fulfill()
            default:
                XCTFail()
            }
            default:
                XCTFail()
            }
        }

        view.presentMessageHandler = { _, _, actions in
            actions[1].execute()
        }

        presenter.logoutButtonTapped()
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatAConfirmationAlertIsShownWhenDeleteAccountButtonIsTapped() {
        XCTAssertEqual(view.presentMessageCallCount, 0)

        presenter.deleteAccountButtonTapped()

        XCTAssertEqual(view.presentMessageCallCount, 1)
    }

    func testThatTheCoordinatorIsAskedToNavigateToDeleteAccountScreenWhenTheUserConfirmsAccountDeletionAlert() {
        let expectation = self.expectation(description: "Alert was shown")
        view.presentMessageHandler = { _, _, actions in
            actions[0].execute()
            expectation.fulfill()
        }
        XCTAssertEqual(coordinator.goToAccountDeletionCallCount, 0)

        presenter.deleteAccountButtonTapped()

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(coordinator.goToAccountDeletionCallCount, 1)
    }
}
