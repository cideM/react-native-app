//
//  DeeplinkAwareWebviewPresenter.swift
//  Knowledge
//
//  Created by Manaf Alabd Alrahim on 29.08.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization
import Networking

public protocol DeeplinkAwareWebviewCoordinatorType: AnyObject {
    func navigate(to deepLink: Deeplink)
    func openInternally(url: URL)
}

public protocol DeeplinkAwareWebviewPresenterType: AnyObject {
    var view: DeeplinkAwareWebViewControllerType? { get set }
    func failedToLoad(with error: Error)
    func canDeeplink(to url: URL) -> Bool
    func openInternally(url: URL)
}

final class DeeplinkAwareWebviewPresenter: DeeplinkAwareWebviewPresenterType {

    private let coordinator: DeeplinkAwareWebviewCoordinatorType?
    private let authenticationClient: AuthenticationClient
    private let appConfiguration: URLConfiguration
    private let lastPathComponent: String
    private let queryParameters: [String: String]
    private let forcedInitialURL: String?

    weak var view: DeeplinkAwareWebViewControllerType? {
        didSet {
            load()
        }
    }

    init(authenticationClient: AuthenticationClient = resolve(),
         appConfiguration: Configuration = AppConfiguration.shared,
         lastPathComponent: String,
         queryParameters: [String: String],
         forcedInitialURL: String? = nil,
         coordinator: DeeplinkAwareWebviewCoordinatorType?) {
        self.authenticationClient = authenticationClient
        self.lastPathComponent = lastPathComponent
        self.queryParameters = queryParameters
        self.appConfiguration = appConfiguration
        self.forcedInitialURL = forcedInitialURL
        self.coordinator = coordinator
    }

    private func load() {
        authenticationClient.issueOneTimeToken { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                var baseURL: URL
                if let forcedInitialURL = self.forcedInitialURL,
                let url = URL(string: forcedInitialURL) {
                    baseURL = url
                        .adding(query: self.queryParameters)
                } else {
                   baseURL = self.appConfiguration.webBaseURL
                        .appendingPathComponent("app2web")
                        .appendingPathComponent(self.lastPathComponent)
                        .adding(query: ["token": token.token])
                        .adding(query: self.queryParameters)
                }

                self.view?.loadRequest(URLRequest(url: baseURL))
            case .failure:
                // Still loading the request in case we can not authenticate,
                // the user will have to manually login then.
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

    func canDeeplink(to url: URL) -> Bool {
        let deeplink = Deeplink(url: url)
        switch deeplink {
        case .learningCard, .monograph, .pharmaCard:
            return true
        default:
            return false
        }
    }

    func openInternally(url: URL) {
        let deeplink = Deeplink(url: url)
        if canDeeplink(to: url) {
            coordinator?.navigate(to: deeplink)
        } else {
            coordinator?.openInternally(url: url)
        }
    }
}
