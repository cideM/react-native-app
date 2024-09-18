//
//  LearningCardOptionsPresenter.swift
//  Knowledge
//
//  Created by CSH on 17.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization

protocol LearningCardOptionsPresenterType {
    var view: LearningCardOptionsViewType? { get set }

    func createQuestionSession()
    func shareLearningCard()
    func toggleIsLearned()
    func highlightingSwitchDidChange(_ isOn: Bool)
    func highYieldModeSwitchDidChange(_ isOn: Bool)
    func physikumFokusSwitchDidChange(_ isOn: Bool)
    func learningRadarSwitchDidChange(_ isOn: Bool)
    func changeFontScale(_ scale: Float)
    func fontSliderTrackingChanged(isTracking: Bool)
    func didTapModeCallout()
}

final class LearningCardOptionsPresenter: LearningCardOptionsPresenterType {

    weak var view: LearningCardOptionsViewType? {
        didSet {
            self.updateView()
        }
    }

    private let optionsRepository: LearningCardOptionsRepositoryType
    private let libraryRepository: LibraryRepositoryType
    private let userDataRepository: UserDataRepositoryType
    private let coordinator: LearningCardCoordinatorType
    private let deviceSettingRepository: DeviceSettingsRepositoryType
    private let learningCardStack: PointableStack<LearningCardDeeplink>
    private let trackingProvider: TrackingType
    private let authorizationRepository: AuthorizationRepositoryType
    private let configuration: Configuration
    private let learningCardShareRepository: LearningCardShareRepostitoryType
    private let tagRepository: TagRepositoryType
    private var tracker: LearningCardTracker?
    private var fontSliderTrackingCallback: ((Bool) -> Void)?
    private var userStageObserver: NSObjectProtocol?

    private lazy var preclinicFocusAvailable: Bool = {
        guard let learningCardIdentifier = learningCardStack.currentItem?.learningCard else {
            return false
        }
        let available = (try? libraryRepository.library.learningCardMetaItem(for: learningCardIdentifier))?.preclinicFocusAvailable ?? false
        return available
    }()

    private var preclinicalFeaturesAvailable: Bool {
        switch configuration.appVariant {
        case .knowledge:
            // US does not have this feature
            return false
        case .wissen:
            // Show preclinical educational features (Physikum Fokus) in DE app when the stage == .preclinic
            return userDataRepository.userStage == .preclinic
        }
    }

    private var educationalFeaturesAvailable: Bool {
        // Show Educational features in DE app when the stage is not physician
        userDataRepository.userStage != .physician
    }

    private var modeSwitcherCalloutVisible: Bool {
        configuration.appVariant == .knowledge && !educationalFeaturesAvailable
    }

    private lazy var learningCardHasQuestions: Bool = {
        guard let learningCardIdentifier = learningCardStack.currentItem?.learningCard else {
            return false
        }
        let questionCount = (try? libraryRepository.library.learningCardMetaItem(for: learningCardIdentifier))?.questions.count ?? 0
        return questionCount > 0
    }()

    private lazy var highYieldModeAvailable: Bool = {
        switch configuration.appVariant {
        case .knowledge: return true
        case .wissen: return false
        }
    }()

    private var isLearned: Bool {
        if let currentItem = learningCardStack.currentItem {
            return tagRepository.hasTag(.learned, for: currentItem.learningCard)
        }
        return false
    }

    private lazy var modeCalloutText: NSAttributedString = {
        let text = NSAttributedString.attributedString(
            with: L10n.LearningCardOptionsView.Callout.text + "\n",
            style: .paragraphSmall)
        let underlinedText = NSAttributedString.attributedString(
            with: L10n.LearningCardOptionsView.Callout.underlinedText,
            style: .paragraphSmall, decorations: [.underline(.textInfo)])

        var result = NSMutableAttributedString(attributedString: text)
        result.append(underlinedText)

        return result
    }()

    init(coordinator: LearningCardCoordinatorType,
         optionsRepository: LearningCardOptionsRepositoryType,
         libraryRepository: LibraryRepositoryType = resolve(),
         userDataRepository: UserDataRepositoryType,
         deviceSettingRepository: DeviceSettingsRepositoryType,
         learningCardStack: PointableStack<LearningCardDeeplink>,
         trackingProvider: TrackingType = resolve(),
         authorizationRepository: AuthorizationRepositoryType = resolve(),
         configuration: Configuration = AppConfiguration.shared,
         learningCardShareRepository: LearningCardShareRepostitoryType,
         tagRepository: TagRepositoryType,
         tracker: LearningCardTracker?) {
        self.coordinator = coordinator
        self.optionsRepository = optionsRepository
        self.libraryRepository = libraryRepository
        self.userDataRepository = userDataRepository
        self.deviceSettingRepository = deviceSettingRepository
        self.learningCardStack = learningCardStack
        self.trackingProvider = trackingProvider
        self.authorizationRepository = authorizationRepository
        self.configuration = configuration
        self.learningCardShareRepository = learningCardShareRepository
        self.tagRepository = tagRepository
        self.tracker = tracker

        userStageObserver = NotificationCenter.default.observe(for: UserStageDidChangeNotification.self, object: userDataRepository, queue: .main) { [weak self] _ in
            self?.updateView()
        }
    }

    func updateView() {

        view?.setShareButton(title: L10n.LearningCardOptionsView.Share.title,
                             image: Asset.Icon.share.image,
                             isEnabled: true)
        view?.setLearnedButton(title: L10n.LearningCardOptionsView.Learned.title,
                               image: isLearned ? Asset.Icon.learnCheck.image : Asset.Icon.learnCircle.image,
                               isEnabled: educationalFeaturesAvailable)
        view?.setQbankButton(title: L10n.LearningCardOptionsView.CreateQuestions.title,
                             image: Asset.Icon.questionSession.image,
                             isEnabled: learningCardHasQuestions && educationalFeaturesAvailable)

        view?.setHighlightingSwitch(title: L10n.LearningCardOptionsView.Modes.Highlighting.title,
                                    subtitle: L10n.LearningCardOptionsView.Modes.Highlighting.subtitle,
                                    isOn: optionsRepository.isHighlightingModeOn,
                                    isEnabled: educationalFeaturesAvailable)
        view?.setHighYieldModeSwitch(title: L10n.LearningCardOptionsView.Modes.HighYield.title,
                                     subtitle: L10n.LearningCardOptionsView.Modes.HighYield.subtitle,
                                     isOn: optionsRepository.isHighYieldModeOn,
                                     isEnabled: highYieldModeAvailable && educationalFeaturesAvailable)
        view?.setPhysikumFokusSwitch(title: L10n.LearningCardOptionsView.Modes.PhysikumFokus.title,
                                     subtitle: L10n.LearningCardOptionsView.Modes.PhysikumFokus.subtitle,
                                     isOn: optionsRepository.isPhysikumFokusModeOn,
                                     isEnabled: preclinicFocusAvailable && preclinicalFeaturesAvailable)
        view?.setLearningRadarSwitch(title: L10n.LearningCardOptionsView.Modes.LearningRadar.title,
                                     subtitle: L10n.LearningCardOptionsView.Modes.LearningRadar.subtitle,
                                     isOn: optionsRepository.isLearningRadarOn,
                                     isEnabled: educationalFeaturesAvailable)
        view?.setModeCallout(text: modeCalloutText,
                             isVisible: modeSwitcherCalloutVisible)
        view?.setFontSize(title: L10n.LearningCardOptionsView.TextSizeCell.title,
                          value: deviceSettingRepository.currentFontScale)

        DispatchQueue.main.async {
            self.view?.updatePreferredContentSize()
        }
    }

    func setfontSliderTrackingCallback(callback: @escaping (Bool) -> Void) {
        self.fontSliderTrackingCallback = callback
    }

    func highlightingSwitchDidChange(_ isOn: Bool) {
        optionsRepository.isHighlightingModeOn = isOn
    }

    func highYieldModeSwitchDidChange(_ isOn: Bool) {
        optionsRepository.isHighYieldModeOn = isOn
    }

    func physikumFokusSwitchDidChange(_ isOn: Bool) {
        optionsRepository.isPhysikumFokusModeOn = isOn
    }

    func learningRadarSwitchDidChange(_ isOn: Bool) {
        optionsRepository.isLearningRadarOn = isOn
    }

    func changeFontScale(_ scale: Float) {
        deviceSettingRepository.currentFontScale = scale
    }

    func createQuestionSession() {
        guard learningCardHasQuestions, let learningCard = learningCardStack.currentItem?.learningCard else { return }
        coordinator.openQBankSessionCreation(for: learningCard)
        trackingProvider.track(.articleCreateSessionClicked(articleID: learningCard.value))
    }

    func shareLearningCard() {
        guard
            let learningCardIdentifier = learningCardStack.currentItem?.learningCard,
            let learningCardMetaItem = try? libraryRepository.library.learningCardMetaItem(for: learningCardIdentifier)
        else { return }

        let userName = authorizationRepository.authorization?.user.firstName ?? ""
        let shareLearningCardItem = learningCardShareRepository.learningCardShareItem(for: learningCardMetaItem, with: userName)
        tracker?.trackPresentShareSheet()
        coordinator.share(shareLearningCardItem) { [weak self] didShare in
            if didShare { self?.tracker?.trackShareSent() }
        }
    }

    func toggleIsLearned() {
        if let currentItem = learningCardStack.currentItem {
            let isLearned = !tagRepository.hasTag(.learned, for: currentItem.learningCard)
            if isLearned {
                tagRepository.addTag(.learned, for: currentItem.learningCard)
            } else {
                tagRepository.removeTag(.learned, for: currentItem.learningCard)
            }
            self.view?.setLearnedButton(title: L10n.LearningCardOptionsView.Learned.title,
                                   image: isLearned ? Asset.Icon.learnCheck.image : Asset.Icon.learnCircle.image,
                                   isEnabled: true)
          tracker?.trackIsLearned(isEnabled: isLearned)
        }
    }

    func fontSliderTrackingChanged(isTracking: Bool) {
        fontSliderTrackingCallback?(isTracking)
    }

    func didTapModeCallout() {
        coordinator.navigateToUserStageSettings()
    }
}
