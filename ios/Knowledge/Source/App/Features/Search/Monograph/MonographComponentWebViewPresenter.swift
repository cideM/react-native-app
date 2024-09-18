//
//  MonographComponentWebViewPresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 13.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

/// `MonographComponent` represents the type of the component that needs to be rendered on a `WKWebView` separated from the monograph view.
enum MonographComponent {
    case references(title: String, htmlContent: String)
    case table(title: String, htmlContent: String)
    case offLabelElement(htmlContent: String)
    case tableAnnotation(htmlContent: String)
}

protocol MonographComponentWebViewPresenterType: MonographWebViewBridgeDelegate {
    var view: MonographComponentWebViewType? { get set }

    func dismissView()
}

final class MonographComponentWebViewPresenter: MonographComponentWebViewPresenterType {

    private let coordinator: MonographCoordinatorType
    private let monographComponent: MonographComponent
    private let deeplink: MonographDeeplink
    private let snippetRepository: SnippetRepositoryType
    private let tracker: MonographPresenter.Tracker
    @Inject private var monitor: Monitoring

    weak var view: MonographComponentWebViewType? {
        didSet {
            view?.load(monographComponent: monographComponent)
        }
    }

    init(coordinator: MonographCoordinatorType, monographComponent: MonographComponent, deeplink: MonographDeeplink, snippetRepository: SnippetRepositoryType, tracker: MonographPresenter.Tracker) {
        self.coordinator = coordinator
        self.monographComponent = monographComponent
        self.deeplink = deeplink
        self.snippetRepository = snippetRepository
        self.tracker = tracker
    }

    func dismissView() {
        coordinator.dismissView()
    }

    private func showSnippet(for snippetIdentifier: SnippetIdentifier) {
        snippetRepository.snippet(for: snippetIdentifier) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let snippet):
                self.coordinator.showSnippetView(with: snippet, for: .monograph(self.deeplink))
            case .failure:
                self.monitor.error("Snippet is not found", context: .monographs)
            }
        }
    }

    func bridge(didReceive event: MonographWebViewBridge.Event) {
        switch event {
        case .initializeEnd, .openTable, .feedbackButtonClicked, .tableAnnotationClicked:
            break
        case .openLinkToAmboss(let learningCardDeeplink):
            coordinator.navigate(to: learningCardDeeplink)
        case .openLinkToSnippet(let snippetIdentifier):
            showSnippet(for: snippetIdentifier)
        case .openLinkToMonograph(let monographDeeplink):
            coordinator.navigate(to: monographDeeplink)
        case .openLinkToExternalPage(let url):
            coordinator.openURLInternally(url)
        case .referenceCalloutGroup(let html):
            coordinator.showMonographComponent(.references(title: L10n.ReferencesCalloutGroup.title, htmlContent: html), tracker: tracker)
        case .offLabelElementClicked(let html):
            coordinator.showMonographComponent(.offLabelElement(htmlContent: html), tracker: tracker)
        }
    }

    func bridge(didFail error: MonographWebViewBridge.Error) {
        monitor.error(error, context: .monographs)
    }

    func bridge(didReceive analyticsEvent: MonographWebViewBridge.AnalyticsEvent) {
        switch analyticsEvent {
        case .genericEvent(let eventName, let properties):
            tracker.trackGenericEvent(eventName: eventName, properties: properties)
        }
    }
}
