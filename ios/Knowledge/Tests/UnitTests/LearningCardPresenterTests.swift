//
//  LearningCardPresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 10.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import XCTest
import Localization

class LearningCardPresenterTests: XCTestCase {

    var learningCardClient: LearningCardLibraryClientMock!
    var userDataClient: UserDataClientMock!
    var library: LibraryTypeMock!
    var libraryRepository: LibraryRepositoryTypeMock!
    var learningCardPresenter: LearningCardPresenterType!
    var learningCardCoordinator: LearningCardCoordinatorTypeMock!
    var learningCardStack: PointableStack<LearningCardDeeplink>!
    var learningCardOptionsRepository: LearningCardOptionsRepositoryType!
    var userDataRepository: UserDataRepositoryType!
    var tagRepository: TagRepositoryType!
    var extensionsRepository: ExtensionRepositoryType!
    var sharedExtensionsRepository: SharedExtensionRepositoryTypeMock!
    var deviceSettingsRepository: DeviceSettingsRepositoryTypeMock!
    var accessRepository: AccessRepositoryTypeMock!
    var galleryRepository: GalleryRepositoryTypeMock!
    var taggingsDidChangeObserver: NSObjectProtocol?
    var sharedExtensionsDidChangeObserver: NSObjectProtocol?
    var extensionsDidChangeObserver: NSObjectProtocol?
    var view: LearningCardViewTypeMock!
    var learningCardShareRepostitory: LearningCardShareRepostitoryTypeMock!
    var qbankRepository: QBankAnswerRepositoryTypeMock!
    var trackingProvider: TrackingTypeMock!
    var readingRepository: ReadingRepositoryTypeMock!
    var snippetRepository: SnippetRepositoryTypeMock!
    var htmlSizeCalculationService: HTMLContentSizeCalculatorTypeMock!
    var inAppPurchaseApplicationService: InAppPurchaseApplicationServiceTypeMock!
    var tracker: LearningCardTracker!
    var webViewBridge: WebViewBridge!

    override func setUp() {
        view = LearningCardViewTypeMock()
        learningCardClient = LearningCardLibraryClientMock()
        userDataClient = UserDataClientMock()
        learningCardCoordinator = LearningCardCoordinatorTypeMock()
        learningCardStack = PointableStack<LearningCardDeeplink>()
        learningCardOptionsRepository = LearningCardOptionsRepository(storage: MemoryStorage())

        userDataRepository = UserDataRepository(storage: MemoryStorage())
        userDataRepository.userStage = .fixture()

        tagRepository = TagRepository(storage: MemoryStorage())
        extensionsRepository = ExtensionRepository(storage: MemoryStorage())
        learningCardShareRepostitory = LearningCardShareRepostitoryTypeMock()
        sharedExtensionsRepository = SharedExtensionRepositoryTypeMock()
        deviceSettingsRepository = DeviceSettingsRepositoryTypeMock()
        accessRepository = AccessRepositoryTypeMock()
        qbankRepository = QBankAnswerRepositoryTypeMock()
        trackingProvider = TrackingTypeMock()
        galleryRepository = GalleryRepositoryTypeMock()
        readingRepository = ReadingRepositoryTypeMock()
        snippetRepository = SnippetRepositoryTypeMock()
        htmlSizeCalculationService = HTMLContentSizeCalculatorTypeMock()

        library = LibraryTypeMock()
        libraryRepository = LibraryRepositoryTypeMock(library: library, learningCardStack: PointableStack<LearningCardDeeplink>())
        library.learningCardMetaItemHandler = { _ in .fixture() }

        tracker = LearningCardTracker(trackingProvider: trackingProvider,
                                                libraryRepository: libraryRepository,
                                                learningCardOptionsRepository: learningCardOptionsRepository,
                                                learningCardStack: learningCardStack,
                                      userStage: userDataRepository.userStage)

        inAppPurchaseApplicationService = InAppPurchaseApplicationServiceTypeMock()
        inAppPurchaseApplicationService.purchaseInfoHandler = {
            InAppPurchaseInfo.fixture(subscriptionState: .subscribed,
                                      canPurchase: true,
                                      hasActiveIAPSubcription: true,
                                      hasProductMetadata: true)
        }
        // Using the US variant cause this one will forward the study objective superset (DE ignores it)
        // See: testThatTheStudyObjectiveIsActivatedToALearningCardOnItsInitialization
        let configuration = ConfigurationMock(appVariant: .knowledge)

        learningCardPresenter = LearningCardPresenter(
            coordinator: learningCardCoordinator,
            libraryRepository: libraryRepository,
            learningCardStack: learningCardStack,
            learningCardOptionsRepository: learningCardOptionsRepository,
            userDataRepository: userDataRepository,
            tagRepository: tagRepository,
            extensionRepository: extensionsRepository,
            learningCardShareRepository: learningCardShareRepostitory,
            authorizationRepository: AuthorizationRepositoryTypeMock(),
            sharedExtensionRepository: sharedExtensionsRepository,
            deviceSettingsRepository: deviceSettingsRepository,
            accessRepository: accessRepository,
            galleryRepository: galleryRepository,
            snippetRepository: snippetRepository,
            remoteConfigRepository: RemoteConfigRepositoryTypeMock(),
            qbankAnswerRepository: qbankRepository,
            trackingProvider: trackingProvider,
            readingRepository: readingRepository,
            userDataClient: userDataClient,
            htmlSizeCalculationService: htmlSizeCalculationService,
            inAppPurchaseApplicationService: inAppPurchaseApplicationService,
            configuration: configuration,
            tracker: tracker)

        webViewBridge = WebViewBridge(delegate: learningCardPresenter)
    }

    func testThatWeArePassingTheCorrectTitleToTheView() {
        let exp = expectation(description: "Title was set")
        accessRepository.getAccessForHandler = { _, completion in
            completion(.success(()))
        }
        library.learningCardMetaItemHandler = { _ in
            LearningCardMetaItem.fixture(title: "Fall (eDocTrainer): \u{00c4}lterer Mann mit Sehst\u{00f6}rung")
        }

        view.setTitleHandler = { title in
            XCTAssertEqual(title, "Fall (eDocTrainer): \u{00c4}lterer Mann mit Sehst\u{00f6}rung")
            exp.fulfill()
        }
        learningCardPresenter.view = view
        learningCardPresenter.go(to: LearningCardDeeplink.fixture(learningCard: .fixture(value: "w70hLh")))

        wait(for: [exp], timeout: 0.1)
    }

    func testThatTheViewIsAskedToRenderTheHtmlOfTheProvidedLearningCard() {
        let exp = expectation(description: "The HTML file location was passed to the view")
        let value = "w70hLh"

        accessRepository.getAccessForHandler = { _, completion in
            completion(.success(()))
        }

        view.loadHandler = { identifier, _ in
            XCTAssertEqual(identifier.value, value)
            exp.fulfill()
        }
        learningCardPresenter.view = view
        learningCardPresenter.go(to: LearningCardDeeplink.fixture(learningCard: .fixture(value: value)))

        wait(for: [exp], timeout: 0.1)
    }

    func testThatATrackingEventIsSentInCaseTheAnchorIDOrParticleIDIsInvalid() {
        let learningCard = LearningCardIdentifier.fixture()
        let anchor = LearningCardAnchorIdentifier.fixture()
        let particle = LearningCardAnchorIdentifier.fixture()
        let deepLink = LearningCardDeeplink.fixture(learningCard: learningCard, anchor: anchor, particle: particle)

        learningCardPresenter.view = view
        accessRepository.getAccessForHandler = { _, completion in
            completion(.success(()))
        }

        let exp = expectation(description: "Tracking event was sent")
        exp.expectedFulfillmentCount = 2

        view.goHandler = { _, _ in
            XCTFail("Should not be called")
        }

        view.loadHandler = { id, onSuccess in
            XCTAssertEqual(id, deepLink.learningCard)
            onSuccess()
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let articleEvent):
                switch articleEvent {
                case .articleAnchorIdInvalid(let articleID, let id):
                    XCTAssertEqual(articleID, learningCard.value)
                    XCTAssertEqual(id, anchor.value)
                    exp.fulfill()
                case .articleParticleIdInvalid(let articleID, let id):
                    XCTAssertEqual(articleID, learningCard.value)
                    XCTAssertEqual(id, particle.value)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        learningCardPresenter.go(to: deepLink)
        wait(for: [exp], timeout: 0.1)
    }

    func testThatTheNextAndPreviousButtonsAreSetToDisabledWhenInitialized() {
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))

        learningCardPresenter.view = view

        XCTAssertFalse(view.canNavigateToNext)
        XCTAssertFalse(view.canNavigateToPrevious)
    }

    func testThatThePreviousButtonIsSetToEnabledForANonEmptyStack() {
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_2")))
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_3")))

        learningCardPresenter.view = view
        learningCardPresenter.goToPreviousLearningCard()

        XCTAssert(view.canNavigateToPrevious)
    }

    func testThatTheNextAndPreviousButtonsAreUpdatedWhenNavigatingBack() {
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_2")))

        learningCardPresenter.view = view

        learningCardPresenter.goToPreviousLearningCard()

        XCTAssert(view.canNavigateToNext)
        XCTAssertFalse(view.canNavigateToPrevious)
    }

    func testThatTheNextAndPreviousButtonsAreUpdatedWhenNavigatingForward() {
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_5")))
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_2")))
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_3")))
        learningCardPresenter.view = view

        learningCardPresenter.goToPreviousLearningCard()
        learningCardPresenter.goToNextLearningCard()

        XCTAssertFalse(view.canNavigateToNext)
        XCTAssert(view.canNavigateToPrevious)
    }

    func testThatADeeplinkIsNotAddedToTheStackIfTheLearningcardIsTheSame() {
        let deeplink = LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1"), anchor: .fixture(value: "spec_anchor_1"))
        learningCardStack.append(deeplink)
        learningCardPresenter.go(to: deeplink)
        learningCardPresenter.view = view

        XCTAssertFalse(view.canNavigateToPrevious)
    }

    func testThatADeeplinkIsAddedToTheStackIfTheLearningcardAnchorIsDifferent() {
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))
        learningCardPresenter.go(to: LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1"), anchor: .fixture(value: "spec_anchor_1")))
        learningCardPresenter.view = view

        XCTAssert(view.canNavigateToPrevious)
    }

    func testThatNavigatingBackUsesTheSourceParameterWhenNavigatingFromOneLearningCardToAnotherOrPassesTheAnchorDirectlyWhenInSameLearningCard() {
        let expectationOnLoad = self.expectation(description: "onLoad or GO was called")
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "w70hLh"), anchor: .fixture(value: "anchor_1"), sourceAnchor: .fixture(value: "source_1")))
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "w70hLh"), anchor: .fixture(value: "anchor_2"), sourceAnchor: .fixture(value: "source_2")))

        learningCardPresenter.view = view

        view.loadHandler = { identifier, _ in
            XCTAssertEqual(identifier.value, "source_2")
            expectationOnLoad.fulfill()
        }
        view.canGoToHandler = { _ in
            return true
        }
        view.goHandler = { anchor, _ in
            XCTAssert(anchor.value == "source_2")
            expectationOnLoad.fulfill()
        }

        learningCardPresenter.goToPreviousLearningCard()
        wait(for: [expectationOnLoad], timeout: 0.5)
    }

    func testThatALearningCardErrorIsPresentedWhenALearningCardHtmlCouldNotBeLoaded() {
        learningCardPresenter.view = view
        learningCardClient.getLearningCardHtmlHandler = { _, _, completion in
            completion(.failure(.other("mocked")))
        }
        library.learningCardMetaItemHandler = { identifier in
            throw LibraryError.missingLearningCard(identifier: identifier)
        }
        accessRepository.getAccessForHandler = { _, completion in
            completion(.success(()))
        }

        let invalidLearningCardDeeplink = LearningCardDeeplink.fixture(learningCard: .fixture(value: "XYZXYZ"))
        learningCardPresenter.go(to: invalidLearningCardDeeplink)

        XCTAssertEqual(view.presentLearningCardErrorCallCount, 1)
    }

    func testThatBydefaultCloseAllSectionsButtonIsHiddenAndOpenAllSectionButtonisNotHidden() {
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))
        learningCardPresenter.view = view
        XCTAssert(view.canOpenAllSections)
    }

    func testThatCloseAllSectionsButtonAndOpenAllSectionsButtonWereSetUponOpenAllSections() {
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))
        learningCardPresenter.view = view
        view.openAllSectionsHandler = {
            self.learningCardPresenter.webViewBridge(
                bridge: self.webViewBridge,
                didReceiveCallback: .init(name: "onSectionOpened", arguments: ["XVa9Gj"])!)
        }
        learningCardPresenter.openAllSections()
        // Can only collapse all sections as soon as one was opened ...
        XCTAssertFalse(view.canOpenAllSections)
    }

    func testThatCloseAndopenAllSectionsButtonWereSetUponCloseAllSections() {
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))
        learningCardPresenter.view = view
        learningCardPresenter.closeAllSections()
        XCTAssert(view.canOpenAllSections)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenOpeningAndClosingAllSections() {
        learningCardPresenter.view = view
        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 2

        let deeplink: LearningCardDeeplink = .fixture()
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink.learningCard)
        library.learningCardMetaItemHandler = { _ in metaItem }

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleExpandAllSections(let articleID, let title):
                    XCTAssertEqual(deeplink.learningCard.value, articleID)
                    XCTAssertEqual(metaItem.title, title)
                    exp.fulfill()
                case .articleCollapseAllSections(let articleID, let title):
                    XCTAssertEqual(deeplink.learningCard.value, articleID)
                    XCTAssertEqual(metaItem.title, title)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        learningCardPresenter.go(to: deeplink)
        learningCardPresenter.openAllSections()
        learningCardPresenter.closeAllSections()

        wait(for: [exp], timeout: 0.1)
    }

    func testThatItPassesShowPopoverCardEventsToTheCoordinator() {
        let expectedHtml = HtmlDocument(headerElements: .fixture(), bodyElements: .fixture())

        let expectedContentSize = CGSize(width: CGFloat(Float.fixture()), height: CGFloat(Float.fixture()))
        htmlSizeCalculationService.calculateSizeHandler = { _, _, completion in
            completion(expectedContentSize)
        }

        let expectation = self.expectation(description: "onShowPopover is called")
        learningCardCoordinator.showPopoverHandler = { html, _, _ in
            XCTAssertEqual(html.asData, expectedHtml.asData)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .showPopover(expectedHtml, tooltipType: nil))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTheCoordinatorReceivesTheExpectedPopoverSizeWhenAskedToPresentPopovers() {
        let expectedHtml = HtmlDocument(headerElements: .fixture(), bodyElements: .fixture())

        let expectedContentSize = CGSize(width: CGFloat(Float.fixture()), height: CGFloat(Float.fixture()))
        htmlSizeCalculationService.calculateSizeHandler = { _, _, completion in
            completion(expectedContentSize)
        }

        let expectation = self.expectation(description: "onShowPopover is called")
        learningCardCoordinator.showPopoverHandler = { _, _, size in
            XCTAssertEqual(size, expectedContentSize)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .showPopover(expectedHtml, tooltipType: nil))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatCallingShowInArticleSearchCallsShowInArticleSearchViewOnTheView() {
        learningCardPresenter.view = view

        learningCardPresenter.showInArticleSearch()

        XCTAssertEqual(view.showInArticleSearchViewCallCount, 1)
    }

    func testThatItPassesShowLearningCardOptionsEventsToTheCoordinator() {
        let expectation = self.expectation(description: "onShowLearningCardOptions is called")
        learningCardCoordinator.showLearningCardOptionsHandler = { _ in
            expectation.fulfill()
        }

        learningCardPresenter.showLearningCardOptions()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatChangingHighlightingModePassesToTheLearningCardPresenterTheCorrectValue() {
        learningCardPresenter.view = view

        view.changeHighlightingModeHandler = { isOn in
            XCTAssertTrue(isOn)
        }

        learningCardOptionsRepository.isHighlightingModeOn = true
    }

    func testThatTheStudyObjectiveIsActivatedToALearningCardOnItsInitialization() {
        learningCardPresenter.view = view

        userDataRepository.studyObjective = StudyObjective.fixture(superset: .some(.fixture()))

        let expectation = self.expectation(description: "Activate study objective is called.")
        view.activateStudyObjectiveHandler = { studyObjective in
            XCTAssertEqual(studyObjective, self.userDataRepository.studyObjective?.superset)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTheWrongAnsweredQuestionsArePassedToTheViewOnLearningCardInitialization() {
        learningCardPresenter.view = view
        learningCardStack.append(LearningCardDeeplink(learningCard: .fixture(value: "spec_x"), anchor: nil, particle: nil, sourceAnchor: nil))
        let repositoryWrongAnswersQuestionIDs: [QBankQuestionIdentifier] = .fixture()
        qbankRepository.wronglyAnsweredQuestionsForHandler = { _ in
            repositoryWrongAnswersQuestionIDs
        }
        let expectation = self.expectation(description: "setWrongAnsweredQuestions is called.")
        view.setWrongAnsweredQuestionsHandler = { questionIDs in
            XCTAssertEqual(repositoryWrongAnswersQuestionIDs, questionIDs)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatHighlightingModeIsSetOnLearningCardInitialization() {
        learningCardPresenter.view = view

        learningCardOptionsRepository.isHighlightingModeOn = true

        let expectation = self.expectation(description: "Change highlighting mode is called.")
        view.changeHighlightingModeHandler = { isOn in
            XCTAssertTrue(isOn)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatHighYieldModeIsSetOnLearningCardInitialization() {
        learningCardPresenter.view = view

        learningCardOptionsRepository.isHighYieldModeOn = true

        let expectation = self.expectation(description: "Change high-yield mode is called")
        view.changeHighYieldModeHandler = { isOn in
            XCTAssertTrue(isOn)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatChangingHighYieldModePassesToTheLearningCardPresenterTheCorrectValue() {
        learningCardPresenter.view = view

        view.changeHighYieldModeHandler = { isOn in
            XCTAssertTrue(isOn)
        }

        learningCardOptionsRepository.isHighYieldModeOn = true
    }

    func testThatPhysikumFokusModeIsSetOnLearningCardInitialization() {
        learningCardPresenter.view = view

        learningCardOptionsRepository.isPhysikumFokusModeOn = true

        let expectation = self.expectation(description: "Change physikum-fokus mode is called")
        view.changePhysikumFokusModeHandler = { isOn in
            XCTAssertTrue(isOn)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatChangingPhysikumFokusModePassesToTheLearningCardPresenterTheCorrectValue() {
        let view = LearningCardViewTypeMock()
        learningCardPresenter.view = view

        view.changePhysikumFokusModeHandler = { isOn in
            XCTAssertTrue(isOn)
        }

        learningCardOptionsRepository.isPhysikumFokusModeOn = true
    }

    func testThatThePhysicianModeIsSetToOnIfTheUserIsPhysician() {
        let exp = expectation(description: "Physcian mode was set on the view")
        userDataRepository.userStage = .physician
        view.setPhysicianModeIsOnHandler = { isOn in
            XCTAssert(isOn)
            exp.fulfill()
        }
        learningCardPresenter.view = view

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [exp], timeout: 0.1)
    }

    func testThatThePhysicianModeIsNotSetIfTheUserIsNotPhysician() {
        let exp = expectation(description: "Physcian mode was set on the view")
        userDataRepository.userStage = .clinic
        view.setPhysicianModeIsOnHandler = { isOn in
            XCTAssertFalse(isOn)
            exp.fulfill()
        }
        learningCardPresenter.view = view

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [exp], timeout: 0.1)
    }

    func testThatASnippetViewCanBePresentedFromTheLearningCardWithTheCorrectParameters() {
        let learningCardDeeplink = LearningCardDeeplink.fixture()

        let expectation = self.expectation(description: "navigate to deeplink is called")
        learningCardCoordinator.navigateHandler = { _, snippetAllowed, shouldPopToRoot in
            XCTAssertTrue(snippetAllowed)
            XCTAssertFalse(shouldPopToRoot)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .openLearningCard(learningCardDeeplink))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatIfALearningCardIsMarkedAsFavoriteATaggingsDidChangeNotificationIsTriggered() {
        learningCardStack.append(LearningCardDeeplink(learningCard: .fixture(value: "spec_x"), anchor: nil, particle: nil, sourceAnchor: nil))
        let view = LearningCardViewTypeMock()
        view.isFavorite = false
        learningCardPresenter.view = view

        let exp = expectation(description: "Notification received")
        taggingsDidChangeObserver = NotificationCenter.default.observe(for: TaggingsDidChangeNotification.self, object: tagRepository, queue: .main) { _ in
            exp.fulfill()
        }

        learningCardPresenter.toggleIsFavorite()

        wait(for: [exp], timeout: 0.5)
    }

    func testThatIfALearningCardIsMarkedAsFavoriteNotificationWasTriggeredTheViewReflectsIt() {
        learningCardStack.append(LearningCardDeeplink(learningCard: .fixture(value: "spec_x"), anchor: nil, particle: nil, sourceAnchor: nil))
        let view = LearningCardViewTypeMock()
        view.isFavorite = false
        learningCardPresenter.view = view

        tagRepository.addTag(.favorite, for: .fixture(value: "spec_x"))

        XCTAssertTrue(view.isFavorite)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenCardIsMarkedAsFavorite() {
        learningCardPresenter.view = view
        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 2

        let deeplink: LearningCardDeeplink = .fixture()
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink.learningCard)
        library.learningCardMetaItemHandler = { _ in metaItem }

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleFavoriteRemoved(let articleID):
                    XCTAssertEqual(deeplink.learningCard.value, articleID)
                    exp.fulfill()
                case .articleFavoriteSet(articleID: let articleID):
                    XCTAssertEqual(deeplink.learningCard.value, articleID)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        learningCardPresenter.go(to: deeplink)
        learningCardPresenter.toggleIsFavorite()
        learningCardPresenter.toggleIsFavorite()

        wait(for: [exp], timeout: 0.1)
    }

    func testThatExtensionsAreSetToALearningCardOnItsInitialization() {
        learningCardPresenter.view = view

        let section = LearningCardSectionIdentifier.fixture(value: "spec_9")
        let learningCard = LearningCardIdentifier.fixture(value: "spec_8")
        let ext = Extension.fixture(learningCard: learningCard, section: section)
        let deepLink = LearningCardDeeplink.fixture(learningCard: learningCard, anchor: .fixture(value: "anchor_1"), sourceAnchor: .fixture(value: "source_1"))
        let bridge = WebViewBridge(delegate: learningCardPresenter)

        let expectation = self.expectation(description: "view setExtensions is called.")

        learningCardStack.append(deepLink)
        extensionsRepository.set(ext: ext)

        view.setExtensionsHandler = { extensions in
            print("i am here \(extensions)")
            XCTAssertEqual(extensions.count, 1)
            XCTAssertEqual(extensions.first, ext)
            expectation.fulfill()
        }

        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSharedExtensionsAreSetToALearningCardOnItsInitialization() {

        learningCardPresenter.view = view

        let section = LearningCardSectionIdentifier.fixture(value: "ez1x7j0")
        let learningCard = LearningCardIdentifier.fixture(value: "sepc_1")
        let ext = Extension.fixture(learningCard: learningCard, section: section)
        let user = User.fixture()
        let bridge = WebViewBridge(delegate: learningCardPresenter)

        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: learningCard))
        extensionsRepository.set(ext: ext)

        sharedExtensionsRepository.sharedExtensionsHandler = { _ in
            [SharedExtension(user: user, ext: ext)]
        }

        let expectation = self.expectation(description: "view setSharedExtensions is called.")

        view.setSharedExtensionsHandler = { sharedExtensions in
            XCTAssertEqual(sharedExtensions.count, 1)
            XCTAssertEqual(sharedExtensions.first?.user, user)
            XCTAssertEqual(sharedExtensions.first?.ext, ext)
            expectation.fulfill()
        }

        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatIfExtensionsDidChangeNotificationIsTriggeredExtensionsAreSetToTheView() {
        learningCardPresenter.view = view
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "w70hLh")))

        NotificationCenter.default.post(ExtensionsDidChangeNotification(oldValue: [], newValue: []), sender: extensionsRepository)

        XCTAssertEqual(view.setExtensionsCallCount, 1)
    }

    func testThatIfSharedExtensionsDidChangeNotificationIsTriggeredSharedExtensionsAreSetToTheView() {
        learningCardPresenter.view = view
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "w70hLh")))

        NotificationCenter.default.post(SharedExtensionsDidChangeNotification(), sender: sharedExtensionsRepository)

        XCTAssertEqual(view.setSharedExtensionsCallCount, 1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenCardIsShared() {
        learningCardPresenter.view = view
        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 1

        let deeplink: LearningCardDeeplink = .fixture()
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink.learningCard)
        library.learningCardMetaItemHandler = { _ in metaItem }
        learningCardShareRepostitory.learningCardShareItemHandler = { _, _ in LearningCardShareItem.fixture() }

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleShareOpened(let articleID):
                    XCTAssertEqual(deeplink.learningCard.value, articleID)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        learningCardPresenter.go(to: deeplink)
        learningCardPresenter.shareLearningCard()

        wait(for: [exp], timeout: 0.1)
    }

    func testThatMarkingALearningCardAsOpenedWorks() {
        accessRepository.getAccessForHandler = { _, completion in
            completion(.success(()))
        }
        learningCardPresenter.view = view

        let deeplink = LearningCardDeeplink(learningCard: .fixture(value: "spec_x"), anchor: nil, particle: nil, sourceAnchor: nil)
        learningCardPresenter.go(to: deeplink)

        XCTAssertTrue(tagRepository.hasTag(.opened, for: deeplink.learningCard))
    }

    func testThatWhenFloatingButtonIsTappedThenLearningCardCallsGetUserModes() {
        learningCardPresenter.view = view

        view.getLearningCardModesHandler = { [view] _ in
            XCTAssertEqual(1, view?.getLearningCardModesCallCount)
        }

        learningCardPresenter.showMiniMap()
    }

    func testThatWhenFloatingButtonIsTappedThenCoordinatorShowMiniMapIsCalledUponSuccessWithCorrectModes() {
        let currentUserModes = ["spec_2", "spec_3"]
        let expectation = self.expectation(description: " learningCardCoordinator showMiniMapHandler is called")
        learningCardStack.append(LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))
        learningCardPresenter.view = view

        view.getLearningCardModesHandler = { result in
            result(.success(currentUserModes))
        }

        learningCardCoordinator.showMiniMapHandler = { _, modes in
            XCTAssertEqual(currentUserModes, modes)
            expectation.fulfill()
        }

        learningCardPresenter.showMiniMap()

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(learningCardCoordinator.showMiniMapCallCount, 1)
    }

    func testThatWhenShareLearningCardIsCalledThenPresenterCallsTheLearningCardMetaItemWithCorrectLearningCard() {
        learningCardStack.append(LearningCardDeeplink(learningCard: .fixture(value: "spec_x"), anchor: nil, particle: nil, sourceAnchor: nil))
        learningCardPresenter.view = view
        let expectation = self.expectation(description: "library learningCardMetadataHandler is called")
        expectation.expectedFulfillmentCount = 2 // 2 because the sharing logic and the tracking code call into "learningCardMetadataHandler"

        learningCardShareRepostitory.learningCardShareItemHandler = { _, _ in
            LearningCardShareItem.fixture(title: "spec_y")
        }

        library.learningCardMetaItemHandler = { indentifier in
            XCTAssertEqual(indentifier, LearningCardIdentifier(value: "spec_x"))
            expectation.fulfill()
            return LearningCardMetaItem.fixture(learningCardIdentifier: indentifier)
        }

        learningCardPresenter.shareLearningCard()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenShareLearningCardIsCalledThenPresenterCallsTheCoodinatorShareLearningCardWithProperItem() {

        learningCardStack.append(LearningCardDeeplink(learningCard: .fixture(value: "spec_x"), anchor: nil, particle: nil, sourceAnchor: nil))
        learningCardPresenter.view = view

        let learningCardShareItem = LearningCardShareItem.fixture(title: "spec_1", message: "spec_2", remoteURL: URL(string: "https://spec_3.com")!)

        learningCardShareRepostitory.learningCardShareItemHandler = { _, _ in
            learningCardShareItem
        }

        library.learningCardMetaItemHandler = { indentifier in
            LearningCardMetaItem.fixture(learningCardIdentifier: indentifier)
        }

        let expectation = self.expectation(description: "learningCardCoordinator shareHandler is called")

        learningCardCoordinator.shareHandler = { item, _ in
            XCTAssertEqual(item, learningCardShareItem)
            expectation.fulfill()
        }

        learningCardPresenter.shareLearningCard()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatLearningCardIsAffectedWhenTheFontSizeIsChanged() {
        let view = LearningCardViewTypeMock()
        learningCardPresenter.view = view

        view.setFontSizeHandler = { size in
            XCTAssertEqual(view.setFontSizeCallCount, 1)
            XCTAssertEqual(size, 15.0)
        }

        deviceSettingsRepository.currentFontScale = 1
    }

    func testThatShowEmailComposerIsCalledWithTheCorrectExternalUser() {
        let user = User.fixture(email: String.fixture())

        sharedExtensionsRepository.userHandler = { _ in
            user
        }

        let expectation = self.expectation(description: "sendMessageToUser is called")
        learningCardCoordinator.sendEmailHandler = { userEmail, _ in
            expectation.fulfill()
            XCTAssertEqual(userEmail, user.email!)
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .sendMessageToUser(user.identifier))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatIsIdleTimerDisabledPropertyIsSetToTrueIfTheRepositoryValueIsEnabled() {
        deviceSettingsRepository.keepScreenOn = true

        learningCardPresenter = nil
        learningCardPresenter = LearningCardPresenter(coordinator: learningCardCoordinator, libraryRepository: libraryRepository, learningCardStack: learningCardStack, learningCardOptionsRepository: learningCardOptionsRepository, userDataRepository: userDataRepository, tagRepository: tagRepository, extensionRepository: extensionsRepository, learningCardShareRepository: learningCardShareRepostitory, authorizationRepository: AuthorizationRepositoryTypeMock(), sharedExtensionRepository: SharedExtensionRepositoryTypeMock(), deviceSettingsRepository: deviceSettingsRepository, accessRepository: AccessRepositoryTypeMock(), galleryRepository: galleryRepository, snippetRepository: snippetRepository, remoteConfigRepository: RemoteConfigRepositoryTypeMock(), qbankAnswerRepository: QBankAnswerRepositoryTypeMock(), trackingProvider: TrackingTypeMock(), readingRepository: ReadingRepositoryTypeMock(), userDataClient: UserDataClientMock(), htmlSizeCalculationService: HTMLContentSizeCalculatorTypeMock(), inAppPurchaseApplicationService: inAppPurchaseApplicationService, tracker: tracker)

        XCTAssertEqual(UIApplication.shared.isIdleTimerDisabled, true)
    }

    func testThatIsIdleTimerDisabledPropertyIsSetToFalseIfTheRepositoryValueIsDisabled() {
        deviceSettingsRepository.keepScreenOn = false

        learningCardPresenter = nil
        learningCardPresenter = LearningCardPresenter(coordinator: learningCardCoordinator, libraryRepository: libraryRepository, learningCardStack: learningCardStack, learningCardOptionsRepository: learningCardOptionsRepository, userDataRepository: userDataRepository, tagRepository: tagRepository, extensionRepository: extensionsRepository, learningCardShareRepository: learningCardShareRepostitory, authorizationRepository: AuthorizationRepositoryTypeMock(), sharedExtensionRepository: SharedExtensionRepositoryTypeMock(), deviceSettingsRepository: deviceSettingsRepository, accessRepository: AccessRepositoryTypeMock(), galleryRepository: galleryRepository, snippetRepository: snippetRepository, remoteConfigRepository: RemoteConfigRepositoryTypeMock(), qbankAnswerRepository: QBankAnswerRepositoryTypeMock(), trackingProvider: TrackingTypeMock(), readingRepository: ReadingRepositoryTypeMock(), userDataClient: UserDataClientMock(), htmlSizeCalculationService: HTMLContentSizeCalculatorTypeMock(), inAppPurchaseApplicationService: inAppPurchaseApplicationService, tracker: tracker)

        XCTAssertEqual(UIApplication.shared.isIdleTimerDisabled, false)
    }

    func testThatIsIdleTimerDisabledPropertyIsSetToFalseInLearningCardPresenterDeinit() {
        deviceSettingsRepository.keepScreenOn = true

        learningCardPresenter = nil
        learningCardPresenter = LearningCardPresenter(coordinator: learningCardCoordinator, libraryRepository: libraryRepository, learningCardStack: learningCardStack, learningCardOptionsRepository: learningCardOptionsRepository, userDataRepository: userDataRepository, tagRepository: tagRepository, extensionRepository: extensionsRepository, learningCardShareRepository: learningCardShareRepostitory, authorizationRepository: AuthorizationRepositoryTypeMock(), sharedExtensionRepository: SharedExtensionRepositoryTypeMock(), deviceSettingsRepository: deviceSettingsRepository, accessRepository: AccessRepositoryTypeMock(), galleryRepository: galleryRepository, snippetRepository: snippetRepository, remoteConfigRepository: RemoteConfigRepositoryTypeMock(), qbankAnswerRepository: QBankAnswerRepositoryTypeMock(), trackingProvider: TrackingTypeMock(), readingRepository: ReadingRepositoryTypeMock(), userDataClient: UserDataClientMock(), htmlSizeCalculationService: HTMLContentSizeCalculatorTypeMock(), inAppPurchaseApplicationService: inAppPurchaseApplicationService, tracker: tracker)
        XCTAssertEqual(UIApplication.shared.isIdleTimerDisabled, true)

        learningCardPresenter = nil

        XCTAssertEqual(UIApplication.shared.isIdleTimerDisabled, false)
    }

    func testThatShowVideoIsCalledWithTheCorrectUrl() {
        let video: Video = .fixture()

        let expectation = self.expectation(description: "navigate to url is called")
        learningCardCoordinator.navigateToTrackerURLHandler = { url, _ in
            XCTAssertEqual(url, video.url)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .showVideo(video))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTryingToOpenLearningCardWithoutHavingValidAccessShowsThePaywall() {
        accessRepository.getAccessForHandler = { _, completion in
            completion(.failure(.offlineAccessExpired))
        }

        learningCardPresenter.view = view
        learningCardPresenter.go(to: LearningCardDeeplink.fixture(learningCard: .fixture(value: "w70hLh")))

        XCTAssertEqual(view.presentLearningCardErrorCallCount, 1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenALearningCardIsOpened() {
        learningCardPresenter.view = view

        let deeplink: LearningCardDeeplink = .fixture()
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink.learningCard)
        learningCardStack.append(deeplink)

        library.learningCardMetaItemHandler = { _ in metaItem }

        let exp = expectation(description: "`.articleOpened` event was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleOpened: exp.fulfill()
                default: XCTFail()
                }
            default: XCTFail()
            }
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenAnotherLearningCardIsSelectedFromCurrentLearningCard() {
        learningCardPresenter.view = view

        let initialDeeplink: LearningCardDeeplink = .fixture()
        let deeplink: LearningCardDeeplink = .fixture()
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink.learningCard)
        learningCardStack.append(initialDeeplink)

        library.learningCardMetaItemHandler = { _ in metaItem }

        let exp = expectation(description: "`.articleSelected` event was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleSelected(let article, let referrer):
                    XCTAssertEqual(deeplink.learningCard.value, article)
                    XCTAssertEqual(referrer, .article)
                    exp.fulfill()
                default: XCTFail()
                }
            default: XCTFail()
            }
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .openLearningCard(deeplink))

        wait(for: [exp], timeout: 0.1)
    }

    func testThatTryingToOpenLearningCardWithoutHavingValidCampusLicenseShowsThePaywall() {
        accessRepository.getAccessForHandler = { _, completion in
            completion(.failure(.campusLicenseUserAccessExpired))
        }

        learningCardPresenter.view = view
        learningCardPresenter.go(to: LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))

        XCTAssertEqual(view.presentLearningCardErrorCallCount, 1)
    }

    func testThatTryingToOpenLearningCardWithAnUnknwonErrorShowsThePaywall() {
        accessRepository.getAccessForHandler = { _, completion in
            completion(.failure(.unknown("test")))
        }

        learningCardPresenter.view = view
        learningCardPresenter.go(to: LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))

        XCTAssertEqual(view.presentLearningCardErrorCallCount, 1)
    }

    func testThatCoordinatorStopsAfterClosingTheLearningCardOverlay() {
        learningCardPresenter.closeLearningCardOverlay()
        XCTAssertEqual(learningCardCoordinator.stopCallCount, 1)
    }

    func testThatPresenterTellsCoordinatorToOpenTheGivenURL() {
        learningCardPresenter.openURL(URL(string: "https://www.amboss.com")!)
        XCTAssertEqual(learningCardCoordinator.openURLExternallyCallCount, 1)
    }

    func testThatTappingOnAnImageThatHasPrimaryExternalAdditionShowsExternalMediaInWebViewDirectly() {

        galleryRepository.primaryExternalAdditionHandler = { _ in ExternalAddition.fixture() }

        let galleryDeeplink = GalleryDeeplink.fixture()
        let bridge = WebViewBridge(delegate: learningCardPresenter) // -> "bridge" is not used anywhere
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .showImageGallery(galleryDeeplink))

        XCTAssertEqual(learningCardCoordinator.navigateToTrackerCallCount, 1)
        XCTAssertEqual(learningCardCoordinator.showImageGalleryCallCount, 0)
    }

    func testThatTappingOnAnImageThatHasNoPrimaryExternalAdditionShowsTheGallery() {

        galleryRepository.primaryExternalAdditionHandler = { _ in nil }

        let galleryDeeplink = GalleryDeeplink.fixture()
        let bridge = WebViewBridge(delegate: learningCardPresenter) // -> "bridge" is not used anywhere
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .showImageGallery(galleryDeeplink))

        XCTAssertEqual(learningCardCoordinator.navigateToCallCount, 0)
        XCTAssertEqual(learningCardCoordinator.showImageGalleryCallCount, 1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenWithCorrectDataWhenAnArticleIsOpenedAfterAnother() {
        learningCardPresenter.view = view
        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 2

        let deeplink1: LearningCardDeeplink = .fixture()
        let metaItem1: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink1.learningCard)
        let deeplink2: LearningCardDeeplink = .fixture()
        let metaItem2: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink2.learningCard)

        var isFirstCheck = true

        // Tracking won't fire if there is no metadata
        library.learningCardMetaItemHandler = { _ in isFirstCheck ? metaItem1 : metaItem2 }

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleOpened(let articleID, let title, let options):
                    if isFirstCheck {
                        isFirstCheck = false

                        XCTAssertEqual(deeplink1.learningCard.value, articleID)
                        XCTAssertEqual(metaItem1.title, title)
                        do {
                            let options = try XCTUnwrap(options)
                            XCTAssertFalse(options.isHighYieldModeOn)
                            XCTAssertFalse(options.isHighlightingModeOn)
                            XCTAssertFalse(options.isPhysikumFokusModeOn)
                            XCTAssertFalse(options.isOnLearningRadarOn)
                        } catch {
                            XCTFail("Options should not be nil")
                        }
                    } else {
                        XCTAssertEqual(deeplink2.learningCard.value, articleID)
                        XCTAssertEqual(metaItem2.title, title)
                    }

                    exp.fulfill()

                default:
                    break
                }
            default:
                XCTFail()
            }
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)

        learningCardPresenter.go(to: deeplink1)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        learningCardPresenter.go(to: deeplink2)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenClosingAnArticle() {
        learningCardPresenter.view = view
        let exp = expectation(description: "trackingProvider was called")

        let deeplink1: LearningCardDeeplink = .fixture()
        let metaItem1: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink1.learningCard)
        let deeplink2: LearningCardDeeplink = .fixture()

        // Tracking won't fire if there is no metadata
        library.learningCardMetaItemHandler = { _ in metaItem1 }

        // This is required to make end reading tracking work
        // It will not fire without a reading
        let start = Date()
        let seconds = TimeInterval(Int.random(in: 100...6000))
        let end = start.addingTimeInterval(seconds)
        let reading = LearningCardReading(learningCard: deeplink1.learningCard, openedAt: start, closedAt: end)
        readingRepository.endReadingHandler = { _ in
            reading
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleClosed(let articleID, let title, let viewingDuration):
                    XCTAssertEqual(articleID, deeplink1.learningCard.value)
                    XCTAssertEqual(title, metaItem1.title)
                    XCTAssertEqual(viewingDuration, Int(seconds))
                    exp.fulfill()
                default:
                    break
                }
            default:
                XCTFail()
            }
        }

        learningCardPresenter.go(to: deeplink1)
        learningCardStack.append(deeplink1)
        learningCardPresenter.go(to: deeplink2) // Required to trigger "articleClosed" event
        wait(for: [exp], timeout: 0.1)
    }

    func testThatTrademarksAreBlurredOnLearningCardInitWhenTheUserHasNotAcceptedHealthCareProfession() {
        learningCardPresenter.view = view

        userDataRepository.hasConfirmedHealthCareProfession = false

        let expectation = self.expectation(description: "Hide Trademarks is called.")
        view.hideTrademarksHandler = {
            XCTAssert(true)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTrademarksAreShownOnLearningCardInitWhenTheUserHasAcceptedHealthCareProfession() {
        learningCardPresenter.view = view

        userDataRepository.hasConfirmedHealthCareProfession = true

        let expectation = self.expectation(description: "Reveal Trademarks is called.")
        view.revealTrademarksHandler = {
            XCTAssert(true)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .`init`)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenABlurredTrademarkIsTappedTheProfessionalDisclaimerIsShown() {
        learningCardPresenter.view = view

        let expectation = self.expectation(description: "Show disclaimer is called.")
        view.showDisclaimerDialogHandler = { _ in
            XCTAssert(true)
            expectation.fulfill()
        }

        let bridge = WebViewBridge(delegate: learningCardPresenter)
        learningCardPresenter.webViewBridge(bridge: bridge, didReceiveCallback: .blurredTrademarkTapped)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatPaywallIsPresentedWithCorrectFieldsForAccessRequiredError() {
        accessRepository.getAccessForHandler = { _, completion in
            completion(.failure(.accessRequired))
        }

        view.presentLearningCardErrorHandler = { message, messageActions in
            XCTAssertEqual(message.title, L10n.InAppPurchase.Paywall.AccessRequired.title)
            XCTAssertEqual(message.body, L10n.InAppPurchase.Paywall.AccessRequired.message)
            XCTAssertEqual(messageActions.first?.style, .primary)
            XCTAssertEqual(messageActions.first?.title, L10n.InAppPurchase.Paywall.buyLicense)
            XCTAssertEqual(messageActions.last?.style, .normal)
            XCTAssertEqual(messageActions.last?.title, L10n.Generic.retry)
        }

        learningCardPresenter.view = view
        learningCardPresenter.go(to: LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))

    }

    func testThatPaywallIsPresentedWithCorrectFieldsForOfflineAccessExpiredError() {
        accessRepository.getAccessForHandler = { _, completion in
            completion(.failure(.offlineAccessExpired))
        }

        view.presentLearningCardErrorHandler = { message, messageActions in
            XCTAssertEqual(message.title, L10n.InAppPurchase.Paywall.OfflineAccessExpired.title)
            XCTAssertEqual(message.body, L10n.InAppPurchase.Paywall.OfflineAccessExpired.message)
            XCTAssertEqual(messageActions.first?.style, .primary)
            XCTAssertEqual(messageActions.first?.title, L10n.InAppPurchase.Paywall.buyLicense)
            XCTAssertEqual(messageActions.last?.style, .normal)
            XCTAssertEqual(messageActions.last?.title, L10n.Generic.retry)
        }

        learningCardPresenter.view = view
        learningCardPresenter.go(to: LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))
    }

    func testThatPaywallIsPresentedWithCorrectFieldsForCampusLicenseUserAccessExpiredError() {
        accessRepository.getAccessForHandler = { _, completion in
            completion(.failure(.campusLicenseUserAccessExpired))
        }

        view.presentLearningCardErrorHandler = { message, messageActions in
            XCTAssertEqual(message.title, L10n.InAppPurchase.Paywall.CampusLicenseExpired.title)
            XCTAssertEqual(message.body, L10n.InAppPurchase.Paywall.CampusLicenseExpired.message)
            XCTAssertEqual(messageActions.first?.style, .primary)
            XCTAssertEqual(messageActions.first?.title, L10n.InAppPurchase.Paywall.buyLicense)
            XCTAssertEqual(messageActions.last?.style, .normal)
            XCTAssertEqual(messageActions.last?.title, L10n.Generic.retry)
        }

        learningCardPresenter.go(to: LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))
        learningCardPresenter.view = view
    }

    func testThatPaywallIsPresentedWithCorrectFieldsForUnknownError() {
        accessRepository.getAccessForHandler = { _, completion in
            completion(.failure(.unknown("")))
        }

        view.presentLearningCardErrorHandler = { message, messageActions in
            XCTAssertEqual(message.title, L10n.InAppPurchase.Paywall.UnknownAccessError.title)
            XCTAssertEqual(message.body, L10n.InAppPurchase.Paywall.UnknownAccessError.message)
            XCTAssertEqual(messageActions.first?.style, .primary)
            XCTAssertEqual(messageActions.first?.title, L10n.Generic.retry)
            XCTAssertEqual(messageActions.last?.style, .normal)
            XCTAssertEqual(messageActions.last?.title, L10n.InAppPurchase.Paywall.buyLicense)
        }

        learningCardPresenter.go(to: LearningCardDeeplink.fixture(learningCard: .fixture(value: "spec_1")))
        learningCardPresenter.view = view
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenNavigatedBackward() {
        learningCardPresenter.view = view
        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 1

        let deeplink: LearningCardDeeplink = .fixture()
        let deeplinkSecond: LearningCardDeeplink = .fixture()
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink.learningCard)
        library.learningCardMetaItemHandler = { _ in metaItem }

        learningCardPresenter.go(to: deeplink)
        learningCardPresenter.go(to: deeplinkSecond)

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleNavigatedBackward:
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        learningCardPresenter.goToPreviousLearningCard()

        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenNavigatedForward() {
        learningCardPresenter.view = view
        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 1

        let deeplink: LearningCardDeeplink = .fixture()
        let deeplinkSecond: LearningCardDeeplink = .fixture()
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink.learningCard)
        library.learningCardMetaItemHandler = { _ in metaItem }

        learningCardPresenter.go(to: deeplink)
        learningCardPresenter.go(to: deeplinkSecond)
        learningCardPresenter.goToPreviousLearningCard()

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleNavigatedForward:
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        learningCardPresenter.goToNextLearningCard()

        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenOpeningTheOptionsMenu() {

        learningCardPresenter.view = view

        let deeplink: LearningCardDeeplink = .fixture()
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink.learningCard)
        learningCardStack.append(deeplink)

        library.learningCardMetaItemHandler = { _ in metaItem }

        let exp = expectation(description: ".articleOptionsMenuOpened event was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleOptionsMenuOpened(let articleID, let userStage):
                    XCTAssertEqual(articleID, deeplink.learningCard.description)
                    XCTAssertEqual(userStage.rawValue.lowercased(), self.userDataRepository.userStage?.rawValue)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default: XCTFail()
            }
        }

        learningCardPresenter.showLearningCardOptions()
        wait(for: [exp], timeout: 0.1)
    }
}

