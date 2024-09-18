//
//  AuthorizedUrlPresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 07.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Networking
import Localization

protocol ManageSharedExtensionsPresenterType: WebViewPresenterType {}

final class ManageSharedExtensionsPresenter: ManageSharedExtensionsPresenterType {
    weak var view: WebViewControllerType? {
        didSet {
            load()
        }
    }
    private let authenticationClient: AuthenticationClient
    private let appConfiguration: URLConfiguration
    private let sharedExtensionsRepository: SharedExtensionRepositoryType

    init(authenticationClient: AuthenticationClient = resolve(), appConfiguration: URLConfiguration = AppConfiguration.shared, sharedExtensionsRepository: SharedExtensionRepositoryType = resolve()) {
        self.authenticationClient = authenticationClient
        self.appConfiguration = appConfiguration
        self.sharedExtensionsRepository = sharedExtensionsRepository
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

    private func load() {
        view?.setIsLoading(true)
        authenticationClient.issueOneTimeToken { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                let url = self.appConfiguration.manageSharedExtensionsURL.adding(query: ["token": token.token])
                self.view?.loadRequest(URLRequest(url: url))
            case .failure:
                self.view?.loadRequest(URLRequest(url: self.appConfiguration.manageSharedExtensionsURL))
            }
            self.view?.setIsLoading(false)
        }
    }

    deinit {
        NotificationCenter.default.post(SharedExtensionsDidChangeNotification(), sender: sharedExtensionsRepository)
    }
}
