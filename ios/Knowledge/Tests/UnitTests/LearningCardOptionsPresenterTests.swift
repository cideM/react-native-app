//
//  LearningCardOptionsPresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 21.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import XCTest

class LearningCardOptionsPresenterTests: XCTestCase {

    var learningCardOptionsPresenter: LearningCardOptionsPresenterType!
    var learningCardCoordinator: LearningCardCoordinatorTypeMock!
    var learningCardOptionsRepository: LearningCardOptionsRepositoryType!
    var library = LibraryTypeMock()
    var libraryRepository: LibraryRepositoryTypeMock!
    var userDataRepository: UserDataRepositoryType!
    var deviceSettingsRepository: DeviceSettingsRepositoryTypeMock!
    var learningCardStack: PointableStack<LearningCardDeeplink>!
    var authorizationRepository: AuthorizationRepositoryTypeMock!
    var trackingProvider: TrackingTypeMock!
    var learningCardShareRepository: LearningCardShareRepostitoryTypeMock!
    var tagRepository: TagRepositoryTypeMock!
    var taggingsDidChangeObserver: NSObjectProtocol?

    override func setUp() {
        learningCardCoordinator = LearningCardCoordinatorTypeMock()
        learningCardOptionsRepository = LearningCardOptionsRepository(storage: MemoryStorage())
        library = LibraryTypeMock()
        libraryRepository = LibraryRepositoryTypeMock(library: library, learningCardStack: PointableStack<LearningCardDeeplink>())
        userDataRepository = UserDataRepository(storage: MemoryStorage())
        deviceSettingsRepository = DeviceSettingsRepositoryTypeMock()
        learningCardStack = PointableStack<LearningCardDeeplink>()
        trackingProvider = TrackingTypeMock()
        authorizationRepository = AuthorizationRepositoryTypeMock()
        learningCardShareRepository = LearningCardShareRepostitoryTypeMock()
        tagRepository = TagRepositoryTypeMock()

        library.learningCardMetaItemHandler = { _ in .fixture() }

        let tracker = LearningCardTracker(trackingProvider: trackingProvider,
                                         libraryRepository: libraryRepository,
                                         learningCardOptionsRepository: learningCardOptionsRepository,
                                         learningCardStack: learningCardStack,
                                         userStage: .fixture())

        learningCardOptionsPresenter = LearningCardOptionsPresenter(
            coordinator: learningCardCoordinator,
            optionsRepository: learningCardOptionsRepository,
            libraryRepository: libraryRepository,
            userDataRepository: userDataRepository,
            deviceSettingRepository: deviceSettingsRepository,
            learningCardStack: learningCardStack,
            trackingProvider: trackingProvider,
            authorizationRepository: authorizationRepository,
            learningCardShareRepository: learningCardShareRepository,
            tagRepository: tagRepository,
            tracker: tracker)
    }

    func testThatWhenHighlightModeIsChangedTheRepositoryGetsCalledWithTheCorrectValue() {
        learningCardOptionsRepository.isHighlightingModeOn = false

        learningCardOptionsPresenter.highlightingSwitchDidChange(true)

        XCTAssertEqual(learningCardOptionsRepository.isHighlightingModeOn, true)
    }

    func testThatWhenHighYieldModeIsChangedTheRepositoryIsNotifiedWithTheCorrectValue() {
        learningCardOptionsRepository.isHighYieldModeOn = false

        learningCardOptionsPresenter.highYieldModeSwitchDidChange(true)

        XCTAssertEqual(learningCardOptionsRepository.isHighYieldModeOn, true)
    }

    func testThatIfAUserDoesNotHaveAStudyObjectiveTheHighYieldModeWillBeDisabled() {
        let view = LearningCardOptionsViewTypeMock()
        userDataRepository.studyObjective = nil

        view.setHighYieldModeSwitchHandler = { _, _, _, isEnabled in
            XCTAssertFalse(isEnabled)
        }

        learningCardOptionsPresenter.view = view
    }

    func testThatWhenPhysikumFokusModeIsChangedTheRepositoryIsNotifiedWithTheCorrectValue() {
        learningCardOptionsRepository.isPhysikumFokusModeOn = false

        learningCardOptionsPresenter.physikumFokusSwitchDidChange(true)

        XCTAssertEqual(learningCardOptionsRepository.isPhysikumFokusModeOn, true)
    }

    func testThatWhenlearningRadarIsChangedTheRepositoryIsNotifiedWithTheCorrectValue() {
        learningCardOptionsRepository.isLearningRadarOn = false

        learningCardOptionsPresenter.learningRadarSwitchDidChange(true)

        XCTAssertEqual(learningCardOptionsRepository.isLearningRadarOn, true)
    }

    func testThatTheFontSizeIsAppliedToTheViewOnViewDidSet() {
        let view = LearningCardOptionsViewTypeMock()

        deviceSettingsRepository.currentFontScale = 1

        view.setFontSizeHandler = { _, size in
            XCTAssertEqual(size, 1)
        }

        learningCardOptionsPresenter.view = view
    }

    func testThatCallingChangeFontSizeUpdatesTheFontSizeStoredInTheDeviceSettingsRepository() {
        deviceSettingsRepository.currentFontScale = 0

        let scale: Float = 1
        learningCardOptionsPresenter.changeFontScale(scale)

        XCTAssertEqual(deviceSettingsRepository.currentFontScale, scale)
    }

    func testThatWhenCreateQuestionSessionIsCalledQBankSessionCreationIsOpened() {
        XCTAssertEqual(learningCardCoordinator.openQBankSessionCreationCallCount, 0)
        library.learningCardMetaItemHandler = {_ in
            LearningCardMetaItem.fixture(questions: [.fixture()])
        }
        learningCardStack.append(.fixture())
        learningCardOptionsPresenter.createQuestionSession()
        XCTAssertEqual(learningCardCoordinator.openQBankSessionCreationCallCount, 1)
    }

    func testThatWhenCreateQuestionSessionIsCalledQBankSessionCreationIsNotOpenedIfQuestionCountIsZero() {
        XCTAssertEqual(learningCardCoordinator.openQBankSessionCreationCallCount, 0)
        learningCardStack.append(.fixture())
        learningCardOptionsPresenter.createQuestionSession()
        XCTAssertEqual(learningCardCoordinator.openQBankSessionCreationCallCount, 0)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenCreatingAQuestionsSession() {
        let exp = expectation(description: "trackingProvider was called")

        let deeplink: LearningCardDeeplink = .fixture()
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink.learningCard, questions: [.fixture()])
        library.learningCardMetaItemHandler = { _ in metaItem }
        learningCardStack.append(deeplink)

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleCreateSessionClicked(let articleID):
                    XCTAssertEqual(deeplink.learningCard.value, articleID)
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        learningCardOptionsPresenter.createQuestionSession()

        wait(for: [exp], timeout: 0.1)
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenCardIsMarkedAsLearned() {
        let exp = expectation(description: "trackingProvider was called")
        exp.expectedFulfillmentCount = 2

        let deeplink: LearningCardDeeplink = .fixture()
        let metaItem: LearningCardMetaItem = .fixture(learningCardIdentifier: deeplink.learningCard, questions: [.fixture()])
        library.learningCardMetaItemHandler = { _ in metaItem }
        learningCardStack.append(deeplink)

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleLearnedToggledOn(let articleID, let locatedOn), .articleLearnedToggledOff(let articleID, let locatedOn):
                    XCTAssertEqual(deeplink.learningCard.value, articleID)
                    XCTAssertEqual(locatedOn, "article")
                    exp.fulfill()
                default:
                    XCTFail()
                }
            default:
                XCTFail()
            }
        }

        learningCardOptionsPresenter.toggleIsLearned() // -> learned
        learningCardOptionsPresenter.toggleIsLearned() // -> not learned

        wait(for: [exp], timeout: 0.1)
    }

    func testThatSetCreateQuestionIsCalledOnViewDidSetWithEnabledAsTrueWhenCardHasQuestions() {
        // Given
        let view = LearningCardOptionsViewTypeMock()
        XCTAssertEqual(view.setQbankButtonCallCount, 0)
        library.learningCardMetaItemHandler = {_ in
            LearningCardMetaItem.fixture(questions: [.fixture()])
        }
        learningCardStack.append(.fixture())

        view.setQbankButtonHandler = { _, _, isEnabled in
            // Then
            XCTAssertTrue(isEnabled)
        }

        // When
        learningCardOptionsPresenter.view = view

        // Then
        XCTAssertEqual(view.setQbankButtonCallCount, 1)
    }

    func testThatSetCreateQuestionIsCalledOnViewDidSetWithEnabledAsFalseWhenCardDoesNotHaveQuestions() {
        // Given
        let view = LearningCardOptionsViewTypeMock()
        XCTAssertEqual(view.setQbankButtonCallCount, 0)
        library.learningCardMetaItemHandler = {_ in
            // No questions added
            LearningCardMetaItem.fixture()
        }
        learningCardStack.append(.fixture())

        view.setQbankButtonHandler = { _, _, isEnabled in
            // Then
            XCTAssertFalse(isEnabled)
        }

        // When
        learningCardOptionsPresenter.view = view

        // Then
        XCTAssertEqual(view.setQbankButtonCallCount, 1)
    }

    func testThatSetPhysikumFokusModeIsCalledOnViewDidSetWithEnabledAsTrueWhenCardHasPreclinicFocusAvailable() {
        // Given
        let view = LearningCardOptionsViewTypeMock()
        userDataRepository.userStage = .preclinic
        XCTAssertEqual(view.setPhysikumFokusSwitchCallCount, 0)
        library.learningCardMetaItemHandler = {_ in
            LearningCardMetaItem.fixture(preclinicFocusAvailable: true)
        }
        learningCardStack.append(.fixture())

        view.setPhysikumFokusSwitchHandler = { _, _, _, isEnabled in
            // Then
            XCTAssertTrue(isEnabled)
        }

        // When
        learningCardOptionsPresenter.view = view

        // Then
        XCTAssertEqual(view.setPhysikumFokusSwitchCallCount, 1)
    }

    func testThatSetPhysikumFokusModeIsCalledOnViewDidSetWithEnabledAsFalseWhenCardDoesNotHavePreclinicFocusAvailable() {
        // Given
        let view = LearningCardOptionsViewTypeMock()
        XCTAssertEqual(view.setPhysikumFokusSwitchCallCount, 0)
        library.learningCardMetaItemHandler = {_ in
            LearningCardMetaItem.fixture(preclinicFocusAvailable: false)
        }
        learningCardStack.append(.fixture())

        view.setPhysikumFokusSwitchHandler = { _, _, _, isEnabled in
            // Then
            XCTAssertFalse(isEnabled)
        }

        // When
        learningCardOptionsPresenter.view = view

        // Then
        XCTAssertEqual(view.setPhysikumFokusSwitchCallCount, 1)
    }

    func testThatIfALearningCardIsMarkedAsLearnedTheTagRepositoryIsUpdated() {
        learningCardStack.append(LearningCardDeeplink(learningCard: .fixture(value: "spec_x"), anchor: nil, particle: nil, sourceAnchor: nil))

        tagRepository.hasTagHandler = { _, _ in
            false // -> not learned
        }

        tagRepository.addTagHandler = { tag, _ in
            XCTAssertEqual(tag, .learned)
        }

        tagRepository.removeTagHandler = { _, _ in
            XCTFail("This should not be called")
        }

        learningCardOptionsPresenter.toggleIsLearned()
    }

    func testThatIfALearningCardIsMarkedAsNotLearnedTheTagRepositoryIsUpdated() {
        learningCardStack.append(LearningCardDeeplink(learningCard: .fixture(value: "spec_x"), anchor: nil, particle: nil, sourceAnchor: nil))

        tagRepository.hasTagHandler = { _, _ in
            true // -> not learned
        }

        tagRepository.addTagHandler = { _, _ in
            XCTFail("This should not be called")
        }

        tagRepository.removeTagHandler = { tag, _ in
            XCTAssertEqual(tag, .learned)
        }

        learningCardOptionsPresenter.toggleIsLearned()
    }

    func testCorrectSwitchesShownForPreclinicUsers() {
        let view = LearningCardOptionsViewTypeMock()
        userDataRepository.userStage = .preclinic

        library.learningCardMetaItemHandler = {_ in
            LearningCardMetaItem.fixture(preclinicFocusAvailable: true)
        }
        learningCardStack.append(.fixture())

        view.setPhysikumFokusSwitchHandler = { _, _, _, isEnabled in
            // Then
            XCTAssertTrue(isEnabled)
        }

        view.setHighlightingSwitchHandler = { _, _, _, isEnabled in
            // Then
            XCTAssertTrue(isEnabled)
        }

        view.setLearningRadarSwitchHandler = { _, _, _, isEnabled in
            // Then
            XCTAssertTrue(isEnabled)
        }

        // When
        learningCardOptionsPresenter.view = view
    }

    func testCorrectSwitchesShownForClinicUsers() {
        let view = LearningCardOptionsViewTypeMock()
        userDataRepository.userStage = .clinic

        library.learningCardMetaItemHandler = {_ in
            LearningCardMetaItem.fixture(preclinicFocusAvailable: true)
        }
        learningCardStack.append(.fixture())

        view.setPhysikumFokusSwitchHandler = { _, _, isOn, isEnabled in
            // Then
            XCTAssertFalse(isEnabled)
            XCTAssertFalse(isOn)
        }

        view.setHighlightingSwitchHandler = { _, _, _, isEnabled in
            // Then
            XCTAssertTrue(isEnabled)
        }

        view.setLearningRadarSwitchHandler = { _, _, _, isEnabled in
            // Then
            XCTAssertTrue(isEnabled)
        }

        // When
        learningCardOptionsPresenter.view = view
    }

    func testCorrectSwitchesShownForPhysicianUsers() {
        let view = LearningCardOptionsViewTypeMock()
        userDataRepository.userStage = .physician

        library.learningCardMetaItemHandler = {_ in
            LearningCardMetaItem.fixture(preclinicFocusAvailable: true)
        }
        learningCardStack.append(.fixture())

        view.setPhysikumFokusSwitchHandler = { _, _, isOn, isEnabled in
            // Then
            XCTAssertFalse(isEnabled)
            XCTAssertFalse(isOn)
        }

        view.setHighlightingSwitchHandler = { _, _, isOn, isEnabled in
            // Then
            XCTAssertFalse(isEnabled)
            XCTAssertFalse(isOn)
        }

        view.setLearningRadarSwitchHandler = { _, _, isOn, isEnabled in
            // Then
            XCTAssertFalse(isEnabled)
            XCTAssertFalse(isOn)
        }

        // When
        learningCardOptionsPresenter.view = view
    }
}
