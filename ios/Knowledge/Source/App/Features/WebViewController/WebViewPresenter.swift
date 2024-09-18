//
//  WebViewPresenter.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 11.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization

final class WebViewPresenter: WebViewPresenterType {
    weak var view: WebViewControllerType? {
        didSet {
            load()
        }
    }

    enum Source {
        case url(URL)
        case html(String)
    }

    private let source: Source

    init(with url: URL) {
        source = .url(url)
    }

    init(with html: String) {
        source = .html(html)
    }

    private func load() {
        switch source {
        case .url(let url):
            view?.loadRequest(URLRequest(url: url))
        case .html(let html):
            view?.loadHTML(html)
        }
    }

    func failedToLoad(with error: Error) {
        let retryAction = MessageAction(title: L10n.Generic.retry, style: .primary) { [weak self] in
            self?.load()
            return true
        }
        if let error = error as? PresentableMessageType {
            view?.showError(error, actions: [retryAction])
        } else {
            view?.showError(UnknownError.unknown, actions: [retryAction])
        }
    }
}
