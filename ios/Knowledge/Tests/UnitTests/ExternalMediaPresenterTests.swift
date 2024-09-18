//
//  ExternalMediaPresenterTests.swift
//  KnowledgeTests
//
//  Created by CSH on 20.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest
import Localization

class ExternalMediaPresenterTests: XCTestCase {
    var presenter: ExternalMediaPresenterType!
    var externalMediaRepository: ExternalMediaRepositoryTypeMock!
    var accessRepository: AccessRepositoryTypeMock!
    var view: WebViewControllerTypeMock!
    var coordinator: ExternalMediaCoordinatorTypeMock!
    var galleryAnalyticsTrackingProvider: GalleryAnalyticsTrackingProviderTypeMock!
    override func setUp() {
        externalMediaRepository = ExternalMediaRepositoryTypeMock()
        accessRepository = AccessRepositoryTypeMock()
        view = WebViewControllerTypeMock()
        coordinator = ExternalMediaCoordinatorTypeMock()
        galleryAnalyticsTrackingProvider = GalleryAnalyticsTrackingProviderTypeMock()

        presenter = ExternalMediaPresenter(externalMediaRepository: externalMediaRepository, accessRepository: accessRepository, coordinator: coordinator, galleryAnalyticsTrackingProvider: galleryAnalyticsTrackingProvider)
    }

    func testThatItFetchesTheExternalAdditionWhenCalled() {
        presenter.fetchAndShowExternalAddition(with: .fixture())
        XCTAssertEqual(externalMediaRepository.getExternalAdditionCallCount, 1)
    }

    func testThatTheLoadingStateIsSetToTheView() {
        let view = WebViewControllerTypeMock()
        view.setIsLoadingHandler = { isLoading in
            XCTAssertTrue(isLoading)
        }
        presenter.view = view
        XCTAssertEqual(view.setIsLoadingCallCount, 1)
    }

    func testThatExternalAdditionFetchingErrorsAreSentToTheView() {
        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.failure(UnknownError.unknown))
        }
        presenter.fetchAndShowExternalAddition(with: .fixture())

        let view = WebViewControllerTypeMock()
        presenter.view = view
        XCTAssertEqual(view.showErrorCallCount, 1)
    }

    func testThatTheUrlIsSentToTheViewWhenFetchedByThePresenter() {
        let expectedResult: ExternalAddition = .fixture(type: .meditricks)
        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.success(expectedResult))
        }

        let view = WebViewControllerTypeMock()

        presenter.view = view

        view.loadRequestHandler = { request in
            XCTAssertEqual(request.url, expectedResult.url)
        }

        accessRepository.getAccessForCompletionHandler = { _, completion in
            completion(.success(()))
        }

        presenter.fetchAndShowExternalAddition(with: .fixture())
        XCTAssertEqual(view.loadRequestCallCount, 1)
    }

    func testThatTheUrlIsSentToTheViewWhenPassedtoThePresenter() {

        let view = WebViewControllerTypeMock()

        presenter.view = view

        let mediaUrl: URL = .fixture()

        view.loadRequestHandler = { request in
            XCTAssertEqual(request.url, mediaUrl)
        }
        presenter.showExternalAddition(with: mediaUrl, and: .fixture())

        XCTAssertEqual(view.loadRequestCallCount, 1)
    }

    func testThatAReferalIsSetForAMeditricksUrl() {
        let expectedResult: ExternalAddition = .fixture(url: URL(string: "https://meditricks.de/any-page")!)
        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.success(expectedResult))
        }

        accessRepository.getAccessForCompletionHandler = { _, completion in
            completion(.success(()))
        }

        let view = WebViewControllerTypeMock()

        view.loadRequestHandler = { request in
            XCTAssertEqual(request.url, expectedResult.url)
            XCTAssertNotNil(request.allHTTPHeaderFields?["Referer"])
        }
        presenter.view = view

        presenter.fetchAndShowExternalAddition(with: .fixture())

        XCTAssertEqual(view.loadRequestCallCount, 1)
    }

    func testThatAHeaderIsSetForAnEasyradiologyUrl() {
        let expectedResult: ExternalAddition = .fixture(url: URL(string: "https://easyradiology.net/any-page")!)
        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.success(expectedResult))
        }

        accessRepository.getAccessForCompletionHandler = { _, completion in
            completion(.success(()))
        }

        let view = WebViewControllerTypeMock()

        view.loadRequestHandler = { request in
            XCTAssertEqual(request.url, expectedResult.url)
            XCTAssertEqual(request.allHTTPHeaderFields?["Referer"], "Amboss")
        }
        presenter.view = view

        presenter.fetchAndShowExternalAddition(with: .fixture())

        XCTAssertEqual(view.loadRequestCallCount, 1)
    }

    func testThatHeaderAreSetForASmartZoomURL() {

        let configurations: [ConfigurationMock] = [
            .init(appVariant: .wissen, smartzoomRefererUrl: .fixture()),
            .init(appVariant: .knowledge, smartzoomRefererUrl: .fixture())
        ]

        for configuration in configurations {

            presenter = ExternalMediaPresenter(externalMediaRepository: externalMediaRepository, accessRepository: accessRepository, coordinator: coordinator, galleryAnalyticsTrackingProvider: galleryAnalyticsTrackingProvider, appConfiguration: configuration)

            let expectedResult: ExternalAddition = .fixture(url: URL(string: "https://embed.smartzoom.com/slide/207780308154032886702")!)
            externalMediaRepository.getExternalAdditionHandler = { _, completion in
                completion(.success(expectedResult))
            }

            accessRepository.getAccessForCompletionHandler = { _, completion in
                completion(.success(()))
            }

            let view = WebViewControllerTypeMock()
            let urlString = configuration.smartzoomRefererUrl.absoluteString

            view.loadRequestHandler = { request in
                XCTAssertEqual(request.url, expectedResult.url)
                XCTAssertEqual(request.allHTTPHeaderFields?["Origin"], urlString)
                XCTAssertEqual(request.allHTTPHeaderFields?["Referer"], urlString)
            }
            presenter.view = view
            presenter.fetchAndShowExternalAddition(with: .fixture())
            XCTAssertEqual(view.loadRequestCallCount, 1)
        }
    }

    func testThatWhenUserHasFeatureAccessThenPresenterLoadsTheViewWithURL() {
        let expectedResult: ExternalAddition = .fixture(url: URL(string: "https://meditricks.de/any-page")!)
        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.success(expectedResult))
        }

        accessRepository.getAccessForCompletionHandler = { _, completion in
            completion(.success(()))
        }

        view.loadRequestHandler = { request in
            XCTAssertEqual(request.url, expectedResult.url)
        }

        presenter.view = view

        presenter.fetchAndShowExternalAddition(with: .fixture())
        XCTAssertEqual(view.loadRequestCallCount, 1)
    }

    func testThatWhenUserHasNoFeatureAccessThenPresenterLoadsTheErrorView() {
        let expectedResult: ExternalAddition = .fixture(url: URL(string: "https://meditricks.de/any-page")!)

        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.success(expectedResult))
        }

        accessRepository.getAccessForCompletionHandler = { _, completion in
            completion(.failure(.accessRequired))
        }

        view.showErrorHandler = { _, _ in }

        presenter.view = view

        presenter.fetchAndShowExternalAddition(with: .fixture())
        XCTAssertEqual(view.showErrorCallCount, 1)
    }

    func testThatWhenUserHasCampusLicenseUserAccessExpiredThenPresenterLoadsTheErrorView() {
        let expectedResult: ExternalAddition = .fixture(url: URL(string: "https://meditricks.de/any-page")!)

        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.success(expectedResult))
        }

        accessRepository.getAccessForCompletionHandler = { _, completion in
            completion(.failure(.campusLicenseUserAccessExpired))
        }

        view.showErrorHandler = { _, _ in }

        presenter.view = view

        presenter.fetchAndShowExternalAddition(with: .fixture())
        XCTAssertEqual(view.showErrorCallCount, 1)
    }

    func testThatPaywallIsPresentedWithCorrectFieldsForAccessRequiredError() {
        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.success(.fixture()))
        }

        accessRepository.getAccessForCompletionHandler = { _, completion in
            completion(.failure(.accessRequired))
        }

        view.showErrorHandler = { message, messageActions in
            XCTAssertEqual(message.title, L10n.InAppPurchase.Paywall.AccessRequired.title)
            XCTAssertEqual(message.body, L10n.InAppPurchase.Paywall.AccessRequired.message)
            XCTAssertEqual(messageActions.first?.style, .primary)
            XCTAssertEqual(messageActions.first?.title, L10n.InAppPurchase.Paywall.buyLicense)
            XCTAssertEqual(messageActions.last?.style, .normal)
            XCTAssertEqual(messageActions.last?.title, L10n.Generic.retry)
        }

        presenter.view = view

        presenter.fetchAndShowExternalAddition(with: .fixture())
    }

    func testThatPaywallIsPresentedWithCorrectFieldsForOfflineAccessExpiredError() {
        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.success(.fixture()))
        }

        accessRepository.getAccessForCompletionHandler = { _, completion in
            completion(.failure(.offlineAccessExpired))
        }
        presenter.fetchAndShowExternalAddition(with: .fixture())

        view.showErrorHandler = { message, messageActions in
            XCTAssertEqual(message.title, L10n.InAppPurchase.Paywall.OfflineAccessExpired.title)
            XCTAssertEqual(message.body, L10n.InAppPurchase.Paywall.OfflineAccessExpired.message)
            XCTAssertEqual(messageActions.first?.style, .primary)
            XCTAssertEqual(messageActions.first?.title, L10n.InAppPurchase.Paywall.buyLicense)
            XCTAssertEqual(messageActions.last?.style, .normal)
            XCTAssertEqual(messageActions.last?.title, L10n.Generic.retry)
        }
        presenter.view = view
    }

    func testThatPaywallIsPresentedWithCorrectFieldsForCampusLicenseUserAccessExpiredError() {
        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.success(.fixture()))
        }

        accessRepository.getAccessForCompletionHandler = { _, completion in
            completion(.failure(.campusLicenseUserAccessExpired))
        }
        presenter.fetchAndShowExternalAddition(with: .fixture())

        view.showErrorHandler = { message, messageActions in
            XCTAssertEqual(message.title, L10n.InAppPurchase.Paywall.CampusLicenseExpired.title)
            XCTAssertEqual(message.body, L10n.InAppPurchase.Paywall.CampusLicenseExpired.message)
            XCTAssertEqual(messageActions.first?.style, .primary)
            XCTAssertEqual(messageActions.first?.title, L10n.InAppPurchase.Paywall.buyLicense)
            XCTAssertEqual(messageActions.last?.style, .normal)
            XCTAssertEqual(messageActions.last?.title, L10n.Generic.retry)
        }

        presenter.view = view
    }

    func testThatPaywallIsPresentedWithCorrectFieldsForUnknownError() {
        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.success(.fixture()))
        }

        accessRepository.getAccessForCompletionHandler = { _, completion in
            completion(.failure(.unknown("")))
        }
        presenter.fetchAndShowExternalAddition(with: .fixture())

        view.showErrorHandler = { message, messageActions in
            XCTAssertEqual(message.title, L10n.InAppPurchase.Paywall.UnknownAccessError.title)
            XCTAssertEqual(message.body, L10n.InAppPurchase.Paywall.UnknownAccessError.message)
            XCTAssertEqual(messageActions.first?.style, .primary)
            XCTAssertEqual(messageActions.first?.title, L10n.Generic.retry)
            XCTAssertEqual(messageActions.last?.style, .normal)
            XCTAssertEqual(messageActions.last?.title, L10n.InAppPurchase.Paywall.buyLicense)
        }

        presenter.view = view
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenExternalMediaIsShown() {

        let externalAddition = ExternalAddition.fixture(type: .smartzoom) // anything except video
        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 1

        externalMediaRepository.getExternalAdditionHandler = { _, completion in
            completion(.success(externalAddition))
        }
        accessRepository.getAccessForCompletionHandler = { _, completion in
            completion(.success(()))
        }
        galleryAnalyticsTrackingProvider.trackShowImageMediaviewerHandler = { _, _, type in
            XCTAssertEqual(externalAddition.type.rawValue, type)
            exp.fulfill()

        }

        presenter.fetchAndShowExternalAddition(with: .fixture())
        wait(for: [exp], timeout: 1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenVideoExternalMediaIsShown() {

        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 1

        let videoUrl: URL = .fixture()

        galleryAnalyticsTrackingProvider.trackShowVideoMediaviewerHandler = { url in
            XCTAssertEqual(videoUrl, url)
            exp.fulfill()

        }

        presenter.showExternalAddition(with: videoUrl, and: .video)
        wait(for: [exp], timeout: 1)
    }
}
