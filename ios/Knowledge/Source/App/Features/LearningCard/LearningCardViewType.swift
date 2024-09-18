//
//  LearningCardViewType.swift
//  Knowledge DE
//
//  Created by Vedran Burojevic on 01/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

/// @mockable
protocol LearningCardViewType: AnyObject {
    var canNavigateToPrevious: Bool { get set }
    var canNavigateToNext: Bool { get set }
    var canOpenAllSections: Bool { get set }
    var isFavorite: Bool { get set }

    func setTitle(_ title: String)
    func load(learningCard: LearningCardIdentifier, onSuccess: @escaping () -> Void)
    func canGoTo(anchor: LearningCardAnchorIdentifier) -> Bool
    func go(to anchor: LearningCardAnchorIdentifier, question: QBankQuestionIdentifier?)
    func setIsLoading(_ isLoading: Bool)
    func presentLearningCardError(_ error: PresentableMessageType, _ actions: [MessageAction])
    func presentMessage(_ message: PresentableMessageType, actions: [MessageAction])
    func closeAllSections()
    func openAllSections()
    func changeHighlightingMode(_ isOn: Bool)
    func changeHighYieldMode(_ isOn: Bool)
    func changePhysikumFokusMode(_ isOn: Bool)
    func changeLearningRadarMode(_ isOn: Bool)
    func setFontSize(size: Float)
    func hideTrademarks()
    func revealTrademarks()
    func revealDosages()
    func showError(title: String, message: String)
    /// Activates the study objective superset for a learning card.
    /// - Parameter studyObjective: Study objective superset, e.g "step-1". In the future the server will return us a superset of this form "study-objective-step-1".
    func activateStudyObjective(_ studyObjective: String)
    func setPhysicianModeIsOn(_ isOn: Bool)

    /// Injects all the user extensions to the learning card.
    /// - Parameter extensions: All the current user extensions.
    func setExtensions(_ extensions: [Extension])

    /// Injects all the user shared extensions to the learning card.
    /// - Parameter sharedExtensions: All the current user's shared extensions (friends' extensions).
    func setSharedExtensions(_ sharedExtensions: [SharedExtension])

    func getLearningCardModes(completion: @escaping (Result<[String], BridgeError>) -> Void)

    func showInArticleSearchView()

    /// Injects the wrong answered questions to the learning card through the bridge.
    /// - Parameter questionIDs: An array containing the IDs of the wrong answered questions
    func setWrongAnsweredQuestions(questionIDs: [QBankQuestionIdentifier])

    /// Presents the HealthProfessionalsDisclaimer.
    /// - Parameters:
    ///   - completion: A completion that will be called with the user's disclaimer choice.
    func showDisclaimerDialog(completion: @escaping (Bool) -> Void)
}
