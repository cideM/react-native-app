//
//  MonographPresenter.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 07.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

protocol MonographPresenterType: MonographWebViewBridgeDelegate {
    var view: MonographViewType? { get set }
    func navigate(to monograph: MonographDeeplink)
    func webViewDidFailToLoad()
    func trackError(_ error: Error)
}

class MonographPresenter: MonographPresenterType {

    weak var view: MonographViewType? {
        didSet {
            load(monographDeeplink: deeplink)
        }
    }

    private let coordinator: MonographCoordinatorType
    private let monographRepository: MonographRepositoryType
    private let snippetRepository: SnippetRepositoryType
    private var deeplink: MonographDeeplink

    @Inject private var monitor: Monitoring
    private let trackingProvider: TrackingType
    private var tracker: Tracker

    init(coordinator: MonographCoordinatorType, deeplink: MonographDeeplink, monographRepository: MonographRepositoryType = resolve(), snippetRepository: SnippetRepositoryType, trackingProvider: TrackingType = resolve(), supportApplicationService: SupportApplicationService = resolve()) {
        self.coordinator = coordinator
        self.monographRepository = monographRepository
        self.snippetRepository = snippetRepository
        self.deeplink = deeplink
        self.trackingProvider = trackingProvider
        self.tracker = MonographPresenter.Tracker(trackingProvider: trackingProvider)
        supportApplicationService.delegate = self
    }

    deinit {
        tracker.trackMonographClosed()
    }

    func navigate(to monograph: MonographDeeplink) {
        self.deeplink = monograph
        self.load(monographDeeplink: monograph)
    }

    private func load(monographDeeplink: MonographDeeplink) {
        view?.setIsLoading(true)
        monographRepository.monograph(with: monographDeeplink.monograph) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let monograph):
                self.tracker.fillMonographData(MonographData(title: monograph.title, identifier: monograph.id.value))
                self.view?.update(with: monograph.title, html: monograph.html, query: monographDeeplink.query)
                self.tracker.trackMonographOpened()
            case .failure(let error):
                self.view?.showError(error, actions: [
                    MessageAction(title: L10n.Substance.NetworkError.retry, style: .primary) {
                        self.load(monographDeeplink: monographDeeplink)
                        return true
                    },

                    MessageAction(title: L10n.Substance.NetworkError.cancel, style: .normal) {
                        self.coordinator.stop(animated: true)
                        return true
                    }
                ])
            }
        }
    }

    private func load(snippetIdentifier: SnippetIdentifier) {
        view?.setIsLoading(true)
        snippetRepository.snippet(for: snippetIdentifier) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let snippet):
                self.coordinator.showSnippetView(with: snippet, for: .monograph(self.deeplink))
            case .failure:
                self.monitor.error("Snippet is not found.", context: .monographs)
            }
            self.view?.setIsLoading(false)
        }
    }

    func webViewDidFailToLoad() {
        let presentableMessage = PresentableMessage(title: L10n.Error.Generic.title, description: L10n.Error.Generic.message, logLevel: .warning)
        self.view?.showError(presentableMessage, actions: [
            MessageAction(title: L10n.Substance.NetworkError.retry, style: .primary) { [weak self] in
                guard let self = self else { return true }
                self.load(monographDeeplink: self.deeplink)
                return true
            },
            MessageAction(title: L10n.Substance.NetworkError.cancel, style: .normal) {
                self.coordinator.stop(animated: true)
                return true
            }
        ])
    }

    func trackError(_ error: Error) {
        monitor.error(error, context: .monographs)
    }
}

extension MonographPresenter {

    func bridge(didReceive analyticsEvent: MonographWebViewBridge.AnalyticsEvent) {
        switch analyticsEvent {
        case .genericEvent(let eventName, let properties):
            tracker.trackGenericEvent(eventName: eventName, properties: properties)
        }
    }

    func bridge(didReceive event: MonographWebViewBridge.Event) {
        switch event {
        case .initializeEnd:
            if let anchor = deeplink.anchor {
                view?.go(to: anchor)
            }
        case .openLinkToMonograph(let monographDeeplink):
            load(monographDeeplink: monographDeeplink)
        case .openLinkToSnippet(let snippet):
            load(snippetIdentifier: snippet)
        case .openLinkToAmboss(let learningCardDeeplink):
            coordinator.navigate(to: learningCardDeeplink)
            tracker.trackArticleSelected(articleId: learningCardDeeplink.learningCard)
        case .openLinkToExternalPage(let url):
            coordinator.openURLInternally(url)
        case .openTable(let title, let html):
            coordinator.showMonographComponent(.table(title: title, htmlContent: html), tracker: tracker)
        case .referenceCalloutGroup(let html):
            coordinator.showMonographComponent(.references(title: L10n.ReferencesCalloutGroup.title, htmlContent: html), tracker: tracker)
        case .feedbackButtonClicked:
            coordinator.sendFeedback()
        case .offLabelElementClicked(let html):
            coordinator.showMonographComponent(.offLabelElement(htmlContent: html), tracker: tracker)
        case .tableAnnotationClicked(let html):
            coordinator.showMonographComponent(.tableAnnotation(htmlContent: html), tracker: tracker)
        }
    }

    func bridge(didFail error: MonographWebViewBridge.Error) {
        monitor.error(error, context: .monographs)
    }
}

extension MonographPresenter: SupportApplicationServiceDelegate {
    func feedbackSubmitted(feedbackText: String) {
        tracker.trackMonographFeedbackSubmitted(feedbackText: feedbackText)
    }
}
