//
//  LibraryCoordinator.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/23/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import DIKit
import Domain
import Networking
import UIKit
import Localization

/// @mockable
protocol LibraryCoordinatorType: Coordinator {
    func goToLibraryTreeItem(_ item: LearningCardTreeItem)
    func goToLearningCardItem(_ identifier: LearningCardIdentifier)
    func goToLearningCardItem(_ deeplink: LearningCardDeeplink)
    func showLearningCard(_ learningCard: LearningCardDeeplink)
    func showPharmaCard(_ pharmaCard: PharmaCardDeeplink)
    func showMonograph(_ monographDeeplink: MonographDeeplink)
    func showSearchView()
    func dismissLearningCard()
}

final class LibraryCoordinator {

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private let libraryRepository: LibraryRepositoryType
    private var libraryDidUpdateObserver: NSObjectProtocol?
    private var learningCardCoordinator: LearningCardCoordinatorType?
    private var lastPharmaCoordinator: PharmaCoordinator?
    private var lastMonographCoordinator: MonographCoordinator?
    private let appReviewPresenter: AppReviewPresenterType
    private let rootCoordinator: RootCoordinator
    private let trackingProvider: TrackingType
    private var featureFlagRepository: FeatureFlagRepositoryType
    private var userDataRepository: UserDataRepositoryType
    private var webViewNavigationController: UINavigationController?

    private var retainedPharmaCoordinator: PharmaCoordinator?

    init(
        _ navigationController: UINavigationController,
        libraryRepository: LibraryRepositoryType = resolve(),
        appReviewPresenter: AppReviewPresenterType = AppReviewPresenter(),
        rootCoordinator: RootCoordinator,
        trackingProvider: TrackingType = resolve(),
        featureFlagRepository: FeatureFlagRepositoryType = resolve(),
        userDataRepository: UserDataRepositoryType = resolve()
    ) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.libraryRepository = libraryRepository
        self.appReviewPresenter = appReviewPresenter
        self.rootCoordinator = rootCoordinator
        self.trackingProvider = trackingProvider
        self.featureFlagRepository = featureFlagRepository
        self.userDataRepository = userDataRepository
    }

    func start(animated: Bool) {
        let libraryPresenter = LibraryPresenter(coordinator: self)
        let libraryViewController = LibraryViewController(presenter: libraryPresenter)
        libraryViewController.navigationItem.largeTitleDisplayMode = .always // The first item should show a large title
        navigationController.pushViewController(libraryViewController, animated: animated)

        libraryDidUpdateObserver = NotificationCenter.default.observe(for: LibraryDidChangeNotification.self, object: libraryRepository, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.navigationController.popToRoot(animated: false)
        }
    }

    func stop(animated: Bool) {
        navigationController.dismissAndPopAll(animated: animated)
        libraryDidUpdateObserver = nil
    }
}

extension LibraryCoordinator: LibraryCoordinatorType {

    func dismissLearningCard() {
        dismissLearningCard(completion: nil)
    }

    func goToLibraryTreeItem(_ item: LearningCardTreeItem) {
        let libraryPresenter = LibraryPresenter(coordinator: self, parent: item)
        let libraryViewController = LibraryViewController(presenter: libraryPresenter)
        navigationController.pushViewController(libraryViewController, animated: true)
    }

    func goToLearningCardItem(_ identifier: LearningCardIdentifier) {
        goToLearningCardItem(LearningCardDeeplink(learningCard: identifier, anchor: nil, particle: nil, sourceAnchor: nil))
    }

    func goToLearningCardItem(_ deeplink: LearningCardDeeplink) {
        let learningCardNavigationController = createLearningCardViewController(with: deeplink)
        navigationController.present(learningCardNavigationController)
    }

    func showLearningCard(_ learningCard: LearningCardDeeplink) {
        if let pharmaCoordinator = lastPharmaCoordinator,
           let learningCardCoordinator = learningCardCoordinator {
            learningCardCoordinator.navigate(to: learningCard, snippetAllowed: false, shouldPopToRoot: false)
            pharmaCoordinator.stop(animated: true)

        } else if let monographCoordinator = lastMonographCoordinator,
                  let learningCardCoordinator = learningCardCoordinator {
            learningCardCoordinator.navigate(to: learningCard, snippetAllowed: false, shouldPopToRoot: false)
            monographCoordinator.stop(animated: true)

        } else if let learningCardCoordinator = learningCardCoordinator {
            return learningCardCoordinator.navigate(to: learningCard, snippetAllowed: false)

        } else {
            if (try? libraryRepository.library.learningCardMetaItem(for: learningCard.learningCard)) != nil {
                let learningCardNavigationController = createLearningCardViewController(with: learningCard)
                UIViewController.openViewControllerAsTopMost(learningCardNavigationController)
            } else {
                handleMissingLearningCardDeepLink(learningCard)
            }
        }
    }

    func showPharmaCard(_ pharmaCard: PharmaCardDeeplink) {
        if let lastPharmaCoordinator = lastPharmaCoordinator, learningCardCoordinator == nil {
            lastPharmaCoordinator.dismissDrugList {
                lastPharmaCoordinator.navigate(to: pharmaCard)
            }
        } else {
            let navigationController = UINavigationController()
            navigationController.view.backgroundColor = ThemeManager.currentTheme.backgroundColor
            navigationController.modalPresentationStyle = .fullScreen
            let pharmaCoordinator = PharmaCoordinator(navigationController,
                                                      rootCoordinator: self.rootCoordinator,
                                                      pharmaCardDeepLink: pharmaCard)
            pharmaCoordinator.delegate = self
            pharmaCoordinator.start(animated: true)

            // Up to two pharma screens migh be stacked on top of each other
            // We need to keep both alive, otherwise the screens close button does not work
            retainedPharmaCoordinator = lastPharmaCoordinator
            lastPharmaCoordinator = pharmaCoordinator

            UIViewController.openViewControllerAsTopMost(navigationController)
        }
    }

    func showMonograph(_ monographDeeplink: MonographDeeplink) {
        if let lastMonographCoordinator = lastMonographCoordinator {
            lastMonographCoordinator.navigate(to: monographDeeplink)
        } else {
            let monographNavigationController = UINavigationController()
            monographNavigationController.modalPresentationStyle = .fullScreen
            monographNavigationController.view.backgroundColor = ThemeManager.currentTheme.backgroundColor

            let monographCoordinator = MonographCoordinator(monographNavigationController,
                                                            deeplink: monographDeeplink,
                                                            rootCoordinator: self.rootCoordinator,
                                                            snippetRepository: SnippetRepository())

            self.lastMonographCoordinator = monographCoordinator
            monographCoordinator.start(animated: true)

            let doneBarButtonItem = UIBarButtonItem(image: Asset.closeButton.image, style: .plain) { [weak monographCoordinator] _ in
                monographCoordinator?.stop(animated: true)
                self.lastMonographCoordinator = nil
            }
            monographCoordinator.rootNavigationController.viewControllers.first?.navigationItem.leftBarButtonItem = doneBarButtonItem

            UIViewController.openViewControllerAsTopMost(monographNavigationController)
        }
    }

    func showSearchView() {
        rootCoordinator.navigate(to: .search(nil))
    }
}

private extension LibraryCoordinator {

    func createLearningCardViewController(with learningCard: LearningCardDeeplink) -> UINavigationController {
        let learningCardNavigationController = UINavigationController()
        learningCardNavigationController.modalPresentationStyle = .fullScreen

        let learningCardCoordinator = LearningCardCoordinator(learningCardNavigationController, libraryCoordinator: self, rootCoordinator: rootCoordinator)
        self.learningCardCoordinator = learningCardCoordinator
        learningCardCoordinator.start(animated: true)
        learningCardCoordinator.navigate(to: learningCard, snippetAllowed: false)

        let doneBarButtonItem = UIBarButtonItem(image: Asset.closeButton.image, style: .plain) { [weak self] _ in self?.dismissLearningCard() }
        learningCardCoordinator.rootNavigationController.viewControllers.first?.navigationItem.leftBarButtonItem = doneBarButtonItem

        return learningCardNavigationController
    }

    private func dismissLearningCard(completion: (() -> Void)?) {
        guard let navigationController = learningCardCoordinator?.rootNavigationController else {
            completion?()
            return
        }

        navigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.learningCardCoordinator?.stop(animated: false)
            self.learningCardCoordinator = nil
            self.appReviewPresenter.displayAppReviewPromptIfNeeded()
            completion?()
        }
    }

    func handleMissingLearningCardDeepLink(_ learningCardDeepLink: LearningCardDeeplink) {
        guard let topMostViewController = UIViewController.topMostViewController else { return }

        let messageAlertPresenter = UIAlertMessagePresenter(presentingViewController: topMostViewController)

        let message = PresentableMessage(
            title: L10n.Error.Deeplink.title,
            description: L10n.Error.Deeplink.Article.message,
            logLevel: .info
        )

        let yesAction = MessageAction(title: L10n.Generic.yes, style: .normal) { [unowned self] () -> Bool in
            self.openSessionCreationInAppToWebViewPresenter(for: learningCardDeepLink)
            return true
        }

        let noAction = MessageAction(title: L10n.Generic.no, style: .normal, handlesError: true)

        messageAlertPresenter.present(message, actions: [noAction, yesAction])
    }

    private func openSessionCreationInAppToWebViewPresenter(for learningCardDeeplink: LearningCardDeeplink) {
        let presenter = AppToWebPresenter(lastPathComponent: "/library/\(learningCardDeeplink.learningCard.description)/\(learningCardDeeplink.anchor?.value ?? "no-anchor")/required_but_not_used", queryParameters: [:])
        let controller = WebViewController(presenter: presenter)
        let webViewNavigationController = UINavigationController(rootViewController: controller)
        webViewNavigationController.modalPresentationStyle = .fullScreen
        self.webViewNavigationController = webViewNavigationController
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissWebView))
        controller.navigationItem.leftBarButtonItem = doneBarButtonItem
        UIViewController.openViewControllerAsTopMost(webViewNavigationController)
        trackMissingLearningCardArticleOpened(for: learningCardDeeplink)
    }

    private func trackMissingLearningCardArticleOpened(for learningCardDeeplink: LearningCardDeeplink) {
        var url = AppConfiguration.shared.articleBaseURL.appendingPathComponent(learningCardDeeplink.learningCard.value)
        if let anchor = learningCardDeeplink.anchor {
            url = url.setting(fragment: anchor.value)
        }
        let articleID = learningCardDeeplink.learningCard.value
        let title = url.absoluteString // Title is not available in this case, using the url instead, this is intentional
        trackingProvider.track(.articleOpened(articleID: articleID, title: title))
    }

    @objc private func dismissWebView() {
        webViewNavigationController?.presentingViewController?.dismiss(animated: true) { [weak self] in
            self?.webViewNavigationController = nil
        }
    }
}

extension LibraryCoordinator: PharmaCoordinatorDelegate {

    func coordinatorDidStop() {
        lastPharmaCoordinator = nil
    }
}
