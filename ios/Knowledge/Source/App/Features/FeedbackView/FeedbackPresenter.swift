//
//  FeedbackPresenter.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 20.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

protocol FeedbackPresenterType: AnyObject {
    var view: FeedbackViewType? { get set }
    var selectedIntention: FeedbackIntention? { get set }
    var feedbackText: String? { get set }

    func selectIntentionTapped()
    func submitFeedback()
}

final class FeedbackPresenter: FeedbackPresenterType {
    weak var view: FeedbackViewType?
    var selectedIntention: FeedbackIntention? {
        didSet {
            guard let selectedIntention = selectedIntention else { return }

            view?.setSelectedIntention(selectedIntention)
            view?.showMessageTextView()
        }
    }
    var feedbackText: String? {
        didSet {
            enableSendFeedbackButtonIfNeeded()
        }
    }
    private let feedbackRepository: FeedbackRepositoryType
    private let deepLink: FeedbackDeeplink
    private let coordinator: LearningCardCoordinatorType
    private let configuration: Configuration
    private let applicationInformation: Application

    init(feedbackRepository: FeedbackRepositoryType = resolve(), deepLink: FeedbackDeeplink, coordinator: LearningCardCoordinatorType, configuration: Configuration = AppConfiguration.shared, applicationInformation: Application = .main) {
        self.feedbackRepository = feedbackRepository
        self.deepLink = deepLink
        self.coordinator = coordinator
        self.configuration = configuration
        self.applicationInformation = applicationInformation
    }

    func selectIntentionTapped() {
        view?.showIntentionsMenu(with: FeedbackIntention.allCases)
    }

    func submitFeedback() {
        guard
            let appVersion = applicationInformation.version,
            let selectedIntention = selectedIntention,
            let feedbackText = feedbackText else {
                return
            }

        let feedbackSource = SectionFeedback.Source(id: deepLink.anchor?.value, version: deepLink.version)

        let appName: SectionFeedback.MobileInfo.AppName
        switch configuration.appVariant {
        case .wissen: appName = .wissen
        case .knowledge: appName = .knowledge
        }

        let mobileInfo = SectionFeedback.MobileInfo(appName: appName, appVersion: appVersion, archiveVersion: deepLink.archiveVersion)
        let sectionFeedback = SectionFeedback(message: feedbackText, intention: selectedIntention, source: feedbackSource, mobileInfo: mobileInfo)

        feedbackRepository.addFeedback(sectionFeedback)
        coordinator.dismissFeedbackView()
    }

    private func enableSendFeedbackButtonIfNeeded() {
        guard selectedIntention != nil, feedbackText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            view?.setSubmitFeedbackButtonIsEnabled(false)
            return
        }
        view?.setSubmitFeedbackButtonIsEnabled(true)
    }
}
