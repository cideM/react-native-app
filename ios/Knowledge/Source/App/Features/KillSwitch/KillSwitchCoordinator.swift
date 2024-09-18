//
//  KillSwitchCoordinator.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 21.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Networking
import UIKit
import Localization
import Domain

protocol KillSwitchCoordinatorType: Coordinator {}

final class KillSwitchCoordinator: KillSwitchCoordinatorType {
    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    @LazyInject private var killSwitchRepository: KillSwitchRepositoryType
    private let deepLinkService: DeepLinkServiceType
    private let authorizationRepository: AuthorizationRepositoryType
    private let userDataClient: UserDataClient
    private let remoteConfig: RemoteConfigRepositoryType

    private var authorizationDidChangeObserver: NSObjectProtocol?
    private var termsDidChangeObserver: NSObjectProtocol?
    private var deprecatedVersionsDidChangeObserver: NSObjectProtocol?

    private lazy var authenticationCoordinator: AuthenticationCoordinatorType = {
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .overFullScreen

        return AuthenticationCoordinator(navigationController, delegate: self)
    }()

    private lazy var libraryInstantiationCoordinator: LibraryInstantiationCoordinator = {
        let libraryInstantiationCoordinator = LibraryInstantiationCoordinator(navigationController.navigationController) { [unowned self] in
            RootCoordinator(
                self.navigationController.navigationController,
                deepLinkService: self.deepLinkService
            )
        }

        return libraryInstantiationCoordinator
    }()

    @Inject var logger: Monitoring

    init(navigationController: UINavigationController,
         deepLinkService: DeepLinkServiceType,
         authorizationRepository: AuthorizationRepositoryType = resolve(),
         userDataClient: UserDataClient = resolve(),
         remoteConfigRepository: RemoteConfigRepositoryType = resolve()) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.deepLinkService = deepLinkService
        self.authorizationRepository = authorizationRepository
        self.userDataClient = userDataClient
        self.remoteConfig = remoteConfigRepository

        authorizationDidChangeObserver = NotificationCenter.default.observe(for: AuthorizationDidChangeNotification.self, object: nil, queue: .main) { [weak self] change in
            guard change.newValue == nil, let self = self else { return }

            authorizationRepository.authorization = nil

            self.authenticationCoordinator.start(animated: false)
            navigationController.present(self.authenticationCoordinator.rootNavigationController, animated: true) {
                self.libraryInstantiationCoordinator.stop(animated: true)

                if let viewController = self.rootNavigationController.presentedViewController, authorizationRepository.accountWasDeleted == true {
                    UIAlertMessagePresenter(presentingViewController: viewController).present(title: L10n.Welcome.AccountWasDeletedAlert.title, message: L10n.Welcome.AccountWasDeletedAlert.message, actions: [.dismiss])

                    authorizationRepository.accountWasDeleted = nil
                }
            }
        }

        termsDidChangeObserver = NotificationCenter.default.observe(for: TermsComplianceRequiredNotification.self, object: nil, queue: .main) { [weak self] change in
            guard
                remoteConfigRepository.termsReAcceptanceEnabled,
                let self = self,
                self.navigationController.presentedViewController == nil
            else { return }

            if change.newValue == true {
                userDataClient.getTermsAndConditions { [weak self] result in
                    switch result {
                    case .success(let terms):
                        guard let terms else { return }
                        DispatchQueue.main.async {

                            let html = HtmlDocument.termsDocument(body: terms.html)
                            let presenter = TermsPresenter(id: terms.id, html: html) { [weak self] id in
                                // Yes, we dismiss the terms in any case!
                                // In case the network call failed the dialog will come up next time
                                // the user brings the app to the foreground.
                                // It's unlikely though  that the network call fails and we did not want to get
                                // the user stuck on the screen if he technically did accept the terms ...
                                self?.navigationController.dismissPresented(animated: true)

                                userDataClient.acceptTermsAndConditions(id: id) { result in
                                    switch result {
                                    case .success:
                                        // No need to do anything here, the users profile will be updated
                                        // with the proper `shouldUpdateTnC` flag
                                        // The process will be kicked of from there again in case
                                        // a new terms approval is required ...
                                        break
                                    case .failure(let error):
                                        self?.logger.error(error, context: .terms)
                                    }
                                }
                            }

                            let controller = TermsViewController(presenter: presenter)
                            controller.modalPresentationStyle = .overFullScreen
                            controller.modalTransitionStyle = .crossDissolve
                            self?.navigationController.present(controller, animated: true)
                        }
                    case .failure(let error):
                        // We just silently fail
                        // It does not make sense to bother the user with the fact that some legal text
                        // that would bother him anyways did not load succesfully ....
                        self?.logger.error(error, context: .terms)
                    }
                }
            }
        }
    }

    func start(animated: Bool) {
        switch killSwitchRepository.deprecationStatus {
        case .deprecated(let url):
            showDeprecatedView(with: url)
        case .notDeprecated:
            if authorizationRepository.authorization == nil {
                authenticationCoordinator.start(animated: true)
                navigationController.present(authenticationCoordinator.rootNavigationController)
            } else {
                libraryInstantiationCoordinator.start(animated: true)
            }

            deprecatedVersionsDidChangeObserver = NotificationCenter.default.observe(for: KillSwitchDeprecationStatusDidChangeNotification.self, object: killSwitchRepository, queue: .main) { [weak self] change in
                guard let self = self, case let .deprecated(url) = change.newValue else { return }
                self.showDeprecatedView(with: url)
                self.stop(animated: animated)
            }
        }
    }

    func stop(animated: Bool) {
        authenticationCoordinator.stop(animated: animated)
        navigationController.dismissAndPopAll(animated: animated)
    }

    private func showDeprecatedView(with url: URL) {
        let presenter = StaticUrlWebViewPresenter(with: url)
        let webViewController = WebViewController(presenter: presenter)
        webViewController.modalPresentationStyle = .fullScreen
        navigationController.present(webViewController, animated: false) {
            webViewController.loadRequest(URLRequest(url: url))
        }
    }

    private func showTermsView() {

    }
}

extension KillSwitchCoordinator: AuthenticationCoordinatorDelegate {
    func loginCompleted() {
        libraryInstantiationCoordinator.start(animated: true)
        authenticationCoordinator.rootNavigationController.dismiss(animated: true) { [weak self] in
            self?.authenticationCoordinator.stop(animated: false)
        }
    }
}
