//
//  RootPresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/23/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

/// @mockable
protocol RootPresenterType: RootCoordinatorDelegate, DeepLinkServiceDelegate {
    var view: RootViewType? { get set }
    func switchTo(_ tab: RootItem)
}

enum RootItem: Int {
    case home
    case library
    case lists
    case settings
}

final class RootPresenter: RootPresenterType {

    // MARK: - Public properties -

    weak var view: RootViewType?

    // MARK: - Private properties -

    private let coordinator: RootCoordinatorType
    private let deepLinkService: DeepLinkServiceType
    private let trackingProvider: TrackingType

    // MARK: - Lifecycle -

    init(
        coordinator: RootCoordinatorType,
        deepLinkService: DeepLinkServiceType,
        trackingProvider: TrackingType = resolve()
    ) {
        self.coordinator = coordinator
        self.deepLinkService = deepLinkService
        self.trackingProvider = trackingProvider
        deepLinkService.delegate = self
        // Defer until coordinator starts and app flow is ready
        deepLinkService.deferDeepLinks = true
    }

    func switchTo(_ tab: RootItem) {
        view?.selectedIndex = tab.rawValue
    }
}

extension RootPresenter {
    func didReceiveDeepLink(_ deeplink: Deeplink) {
        trackDidReceiveDeepLink(deeplink)
        coordinator.navigate(to: deeplink)
        switch deeplink {
        case let .learningCard(learningCardDeepLink):
            trackArticleSelected(articleId: learningCardDeepLink.learningCard)
        default: break
        }
    }

    private func trackArticleSelected(articleId: LearningCardIdentifier) {
        self.trackingProvider.track(.articleSelected(articleID: articleId.value, referrer: .deepLink))
    }

    private func trackDidReceiveDeepLink(_ deeplink: Deeplink) {
        if case let .search(_, source) = deeplink, source == .siri {
            trackingProvider.track(.searchSiriShortcutExecuted)
        }
    }
}

extension RootPresenter: RootCoordinatorDelegate {

    func didStart() {
        deepLinkService.deferDeepLinks = false
        coordinator.showStartupDialogs()
    }

    func didStop() {
        deepLinkService.deferDeepLinks = true
    }

}
