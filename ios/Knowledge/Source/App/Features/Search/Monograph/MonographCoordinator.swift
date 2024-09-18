//
//  MonographCoordinator.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 07.07.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//
import Common
import Domain
import UIKit

/// @mockable
protocol MonographCoordinatorType: Coordinator {
    func navigate(to monograph: MonographDeeplink)
    func showSnippetView(with snippet: Snippet, for deeplink: Deeplink)
    func navigate(to learningCard: LearningCardDeeplink)
    func openURLInternally(_ url: URL)
    func showMonographComponent(_ monographComponent: MonographComponent, tracker: MonographPresenter.Tracker)
    func sendFeedback()
    func dismissView()
}

class MonographCoordinator: MonographCoordinatorType {

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private let deeplink: MonographDeeplink
    private let rootCoordinator: RootCoordinator
    private let snippetRepository: SnippetRepositoryType
    private let supportApplicationService: SupportApplicationService
    private let supportRequestFactory: SupportRequestFactory
    private weak var monographPresenter: MonographPresenter?
    private var cardTransition: CardPresentationTransitioningManager?

    init(_ navigationController: UINavigationController, deeplink: MonographDeeplink, rootCoordinator: RootCoordinator, snippetRepository: SnippetRepositoryType, supportApplicationService: SupportApplicationService = resolve(), supportRequestFactory: SupportRequestFactory = resolve()) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.deeplink = deeplink
        self.snippetRepository = snippetRepository
        self.supportApplicationService = supportApplicationService
        self.supportRequestFactory = supportRequestFactory
        self.rootCoordinator = rootCoordinator
    }

    func start(animated: Bool) {
        let presenter = MonographPresenter(coordinator: self, deeplink: deeplink, snippetRepository: snippetRepository)
        self.monographPresenter = presenter
        let viewController = MonographViewController(presenter: presenter)
        navigationController.pushViewController(viewController, animated: animated)
    }

    func stop(animated: Bool) {
        navigationController.dismissAndPopAll(animated: animated) { [weak self] in
            self?.navigationController.navigationController.dismiss(animated: animated)
        }
    }

    func navigate(to monograph: MonographDeeplink) {
        if let presenter = monographPresenter {
            presenter.navigate(to: monograph)
        } else {
            let presenter = MonographPresenter(coordinator: self, deeplink: deeplink, snippetRepository: snippetRepository)
            self.monographPresenter = presenter
            let viewController = MonographViewController(presenter: presenter)
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    func showSnippetView(with snippet: Snippet, for deeplink: Deeplink) {
        let presenter = SnippetPresenter(coordinator: self, snippet: snippet, deeplink: deeplink, trackingProvider: PharmaSnippetTracker())
        let view = SnippetViewController.viewController(with: presenter)

        cardTransition = CardPresentationTransitioningManager(edge: .bottom, fullScreenWidth: false)
        view.modalPresentationStyle = .custom
        view.transitioningDelegate = cardTransition

        self.navigationController.present(view)
    }

    func showMonographComponent(_ monographComponent: MonographComponent, tracker: MonographPresenter.Tracker) {
        let presenter = MonographComponentWebViewPresenter(coordinator: self, monographComponent: monographComponent, deeplink: deeplink, snippetRepository: snippetRepository, tracker: tracker)
        let viewController = MonographComponentWebViewController(presenter: presenter)
        let cardTransition = CardPresentationTransitioningManager(edge: .bottom)

        switch monographComponent {
        case .references, .offLabelElement, .tableAnnotation:
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = cardTransition
            self.navigationController.present(viewController)
        case .table:
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }

    func dismissView() {
        self.navigationController.dismissPresented()
    }

    func navigate(to learningCard: LearningCardDeeplink) {
        rootCoordinator.navigate(to: .learningCard(learningCard))
    }

    func openURLInternally(_ url: URL) {
        navigationController.dismissPresented(animated: true) { [weak self] in
            guard let self = self else { return }
            let webCoordinator = WebCoordinator(self.rootNavigationController, url: url, navigationType: .internal(modalPresentationStyle: .currentContext))
            webCoordinator.start(animated: true)
        }
    }

    func sendFeedback() {
        supportApplicationService.showRequestViewController(on: navigationController.navigationController, requestType: supportRequestFactory.monographSupportRequest(monographId: deeplink.monograph))
    }
}

extension MonographCoordinator: SnippetLearningCardDisplayer {
    func navigate(to deeplink: LearningCardDeeplink, shouldPopToRoot: Bool) {
        rootCoordinator.navigate(to: .learningCard(deeplink))
    }
}
