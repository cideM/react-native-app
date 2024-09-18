//
//  WebCoordinator.swift
//  Knowledge
//
//  Created by Vedran Burojevic on 09/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import SafariServices
import UIKit

protocol WebCoordinatorType: Coordinator {}

final class WebCoordinator: WebCoordinatorType {

    enum NavigationType {
        case `internal`(modalPresentationStyle: UIModalPresentationStyle) // SFSafariViewController
        case external // Safari
    }

    // MARK: - Public properties -

    let rootNavigationController: UINavigationController

    // MARK: - Private properties -

    private let url: URL
    private let navigationType: NavigationType
    @Inject private var monitor: Monitoring

    // MARK: - Lifecycle -

    init(_ navigationController: UINavigationController, url: URL, navigationType: NavigationType) {
        self.rootNavigationController = navigationController
        self.url = url
        self.navigationType = navigationType
    }
}

extension WebCoordinator {

    func start(animated: Bool) {
        guard ["https", "http"].contains(url.scheme) else { return assertionFailure("Trying to open a URL that has a non-http(s) scheme.") }

        switch navigationType {
        case let .internal(modalPresentationStyle):
            openURLInternally(url, animated: animated, modalPresentationStyle: modalPresentationStyle)
        case .external:
            openURLExternally(url)
        }
    }

    func stop(animated: Bool) {
        let topMostViewController = UIViewController.topMost(of: rootNavigationController)
        topMostViewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}

private extension WebCoordinator {

    func openURLInternally(_ url: URL, animated: Bool, modalPresentationStyle: UIModalPresentationStyle) {
        let webViewController = SFSafariViewController(url: url)
        webViewController.modalPresentationStyle = modalPresentationStyle
        webViewController.preferredBarTintColor = .backgroundAccent
        webViewController.preferredControlTintColor = ThemeManager.currentTheme.navigationBarItemColor

        let topMostViewController = UIViewController.topMost(of: rootNavigationController)
        topMostViewController.present(webViewController, animated: true)
    }

    func openURLExternally(_ url: URL) {
        guard UIApplication.shared.canOpenURL(url) else {
            monitor.error("UIApplication can't open the following url: \(url)", context: .navigation)
            return
        }

        UIApplication.shared.open(url)
    }

}
