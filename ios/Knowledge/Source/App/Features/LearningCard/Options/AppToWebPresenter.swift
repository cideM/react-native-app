//
//  AppToWebPresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 03.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Networking
import Localization

final class AppToWebPresenter: WebViewPresenterType {

    private let authenticationClient: AuthenticationClient
    private let appConfiguration: URLConfiguration
    private let lastPathComponent: String
    private let queryParameters: [String: String]

    weak var view: WebViewControllerType? {
        didSet {
            load()
        }
    }

    init(authenticationClient: AuthenticationClient = resolve(), appConfiguration: Configuration = AppConfiguration.shared, lastPathComponent: String, queryParameters: [String: String]) {
        self.authenticationClient = authenticationClient
        self.lastPathComponent = lastPathComponent
        self.queryParameters = queryParameters
        self.appConfiguration = appConfiguration
    }

    private func load() {
        authenticationClient.issueOneTimeToken { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                let url = self.appConfiguration.webBaseURL
                    .appendingPathComponent("app2web")
                    .appendingPathComponent(self.lastPathComponent)
                    .adding(query: ["token": token.token])
                    .adding(query: self.queryParameters)
                self.view?.loadRequest(URLRequest(url: url))
            case .failure:
                self.view?.loadRequest(URLRequest(url: self.appConfiguration.webBaseURL))
            }
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
