//
//  StaticUrlWebViewPresenter.swift
//  Common
//
//  Created by Mohamed Abdul Hameed on 24.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization

/// Responsible for presenting a static URL on a `WebViewControllerType`
public final class StaticUrlWebViewPresenter: WebViewPresenterType {
    public var view: WebViewControllerType? {
        didSet {
            view?.loadRequest(URLRequest(url: url))
        }
    }

    private let url: URL

    public init(with url: URL) {
        self.url = url
    }

    public func failedToLoad(with error: Error) {
        let retryAction = MessageAction(title: L10n.Generic.retry, style: .primary) { [weak self] in
            guard let self = self else { return true }

            self.view?.loadRequest(URLRequest(url: self.url))
            return true
        }
        if let error = error as? PresentableMessageType {
            view?.showError(error, actions: [retryAction])
        } else {
            view?.showError(UnknownError.unknown, actions: [retryAction])
        }
    }
}
