//
//  SnippetPresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 12.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

protocol SnippetPresenterType {
    var view: SnippetViewType? { get set }
    func go(to deeplink: LearningCardDeeplink)
}

final class SnippetPresenter: SnippetPresenterType {

    weak var view: SnippetViewType? {
        didSet {
            view?.setViewData(snippet, for: deeplink)
        }
    }

    private let coordinator: SnippetLearningCardDisplayer
    private let snippet: Snippet
    private let deeplink: Deeplink
    private let trackingProvider: SnippetTrackingProvider

    init(coordinator: SnippetLearningCardDisplayer, snippet: Snippet, deeplink: Deeplink, trackingProvider: SnippetTrackingProvider) {
        self.snippet = snippet
        self.coordinator = coordinator
        self.deeplink = deeplink
        self.trackingProvider = trackingProvider
    }

    func go(to deeplink: LearningCardDeeplink) {
        coordinator.navigate(to: deeplink, shouldPopToRoot: true)
        trackingProvider.track(learningCard: deeplink.learningCard)
    }
}
