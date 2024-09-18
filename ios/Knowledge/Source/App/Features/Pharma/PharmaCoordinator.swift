//
//  PharmaCoordinator.swift
//  Knowledge
//
//  Created by Silvio Bulla on 30.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit

protocol PharmaCoordinatorDelegate: AnyObject {
    func coordinatorDidStop()
}

/// @mockable
protocol PharmaCoordinatorType: Coordinator {

    var delegate: PharmaCoordinatorDelegate? { get set }

    func navigate(to pharmaCard: PharmaCardDeeplink)
    func navigate(to learningCard: LearningCardDeeplink)
    func openPDF(with url: URL, title: String)
    func sendFeedback()
    func showDrugList(for substanceIdentifier: SubstanceIdentifier, tracker: PharmaPagePresenter.Tracker, delegate: DrugListDelegate?)
    func showSnippetView(with snippet: Snippet, for deeplink: Deeplink)
    func dismissDrugList(completion: (() -> Void)?)
    func openURLInternally(_ url: URL)
    func openURLExternally(_ url: URL)
    func showPricesAndPackageSizes(data: [PriceAndPackage])
    func dismissPricesAndPackagesView()
}

class PharmaCoordinator: PharmaCoordinatorType {

    weak var delegate: PharmaCoordinatorDelegate?

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }
    private let supportApplicationService: SupportApplicationService
    private let navigationController: SectionedNavigationController
    private let rootCoordinator: RootCoordinator
    private let supportRequestFactory: SupportRequestFactory
    private var pharmaCardDeepLink: PharmaCardDeeplink
    private var snippetRepository: SnippetRepositoryType
    private let pharmaRepository: PharmaRepositoryType
    private let trackingProvider: TrackingType

    private weak var pdfNavigationController: UINavigationController?
    private var cardTransition: CardPresentationTransitioningManager?
    private var presenter: PharmaPagePresenter?

    init(_ navigationController: UINavigationController,
         rootCoordinator: RootCoordinator,
         pharmaCardDeepLink: PharmaCardDeeplink,
         supportApplicationService: SupportApplicationService = resolve(),
         supportRequestFactory: SupportRequestFactory = resolve(),
         snippetRepository: SnippetRepositoryType = resolve(),
         pharmaRepository: PharmaRepositoryType = resolve(),
         trackingProvider: TrackingType = resolve()) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.supportApplicationService = supportApplicationService
        self.supportRequestFactory = supportRequestFactory
        self.rootCoordinator = rootCoordinator
        self.pharmaCardDeepLink = pharmaCardDeepLink
        self.snippetRepository = snippetRepository
        self.pharmaRepository = pharmaRepository
        self.trackingProvider = trackingProvider
    }

    func start(animated: Bool) {
        let presenter = pharmaPresenter()
        self.presenter = presenter
        let pharmaViewController = PharmaPageViewController(presenter: presenter)
        navigationController.pushViewController(pharmaViewController, animated: animated)
    }

    func stop(animated: Bool) {
        navigationController.dismissAndPopAll(animated: animated) { [weak self] in
            self?.navigationController.navigationController.dismiss(animated: animated)
            self?.delegate?.coordinatorDidStop()
        }
    }

    func navigate(to pharmaCard: PharmaCardDeeplink) {
        dismiss() // A modal snippet might stil sit on top

        if let presenter {
            pharmaCardDeepLink = pharmaCard
            dismissDrugList()
            presenter.loadPharmaCard(deeplink: pharmaCard)

        } else {
            let presenter = pharmaPresenter()
            self.presenter = presenter
            let pharmaViewController = PharmaPageViewController(presenter: presenter)
            let pharmaNavigationController = createNavigationControllerWithDoneBarButton(viewController: pharmaViewController)
            navigationController.dismissPresented(animated: true) { [weak self] in
                self?.navigationController.present(pharmaNavigationController)
            }
        }
    }

    func navigate(to learningCard: LearningCardDeeplink) {
        rootCoordinator.navigate(to: .learningCard(learningCard))
    }

    private func createNavigationControllerWithDoneBarButton(viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(viewController, animated: false)
        return navigationController
    }

    @objc private func dismissPharmaView() {
        navigationController.dismissPresented(animated: true)
    }

    func sendFeedback() {
        supportApplicationService.showRequestViewController(
            on: navigationController.navigationController,
            requestType: supportRequestFactory.pharmaSupportRequest(substanceId: pharmaCardDeepLink.substance, drugId: pharmaCardDeepLink.drug))
    }

    func showDrugList(for substanceIdentifier: SubstanceIdentifier, tracker: PharmaPagePresenter.Tracker, delegate: DrugListDelegate?) {
        let drugListPresenter = DrugListPresenter(coordinator: self, pharmaRepository: pharmaRepository, substanceIdentifier: substanceIdentifier, tracker: tracker, delegate: delegate)
        let drugListViewController = DrugListViewController(presenter: drugListPresenter)
        self.navigationController.present(drugListViewController, animated: true)
    }

    func showSnippetView(with snippet: Snippet, for deeplink: Deeplink) {
        let presenter = SnippetPresenter(coordinator: self, snippet: snippet, deeplink: deeplink, trackingProvider: PharmaSnippetTracker())
        let snippetViewController = SnippetViewController.viewController(with: presenter)
        let wrapper = PopoverContainerViewController(child: snippetViewController)

        cardTransition = CardPresentationTransitioningManager(edge: .bottom)
        wrapper.modalPresentationStyle = .custom
        wrapper.transitioningDelegate = cardTransition

        self.navigationController.present(wrapper)
    }

    func dismissDrugList(completion: (() -> Void)? = nil) {
        navigationController.dismissPresented(animated: true, completion: completion)
    }

    func openPDF(with url: URL, title: String) {
        let presenter = PDFViewerPresenter(coordinator: self, url: url, title: title)
        let viewController = PDFViewerViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.pdfNavigationController = navigationController
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss))
        viewController.navigationItem.leftBarButtonItem = doneBarButtonItem
        self.navigationController.present(navigationController, animated: true)
    }

    @objc private func dismiss() {
        navigationController.dismissPresented()
    }

    func openURLInternally(_ url: URL) {
        let webCoordinator = WebCoordinator(rootNavigationController, url: url, navigationType: .internal(modalPresentationStyle: .fullScreen))
        webCoordinator.start(animated: true)
    }

    func openURLExternally(_ url: URL) {
        let webCoordinator = WebCoordinator(rootNavigationController, url: url, navigationType: .external)
        webCoordinator.start(animated: true)
    }

    func showPricesAndPackageSizes(data: [PriceAndPackage]) {
        let presenter = PricesAndPackagesPresenter(coordinator: self, data: data)
        let view = PricesAndPackagesViewController(presenter: presenter)
        cardTransition = CardPresentationTransitioningManager(edge: .bottom)
        view.modalPresentationStyle = .custom
        view.transitioningDelegate = cardTransition
        self.navigationController.present(view)
    }

    func dismissPricesAndPackagesView() {
        navigationController.dismissPresented()
    }

    private func pharmaPresenter() -> PharmaPagePresenter {
        let tracker = PharmaPagePresenter.Tracker(trackingProvider: trackingProvider)
        let ifap = {
            let presenter = PharmaPresenter(coordinator: self, pharmaRepository: pharmaRepository)
            let view = PharmaViewController(presenter: presenter)
            view.layout.shouldPinHeaders = true
            return (presenter, view)
        }()
        let pocketCard = {
            let presenter = PharmaPresenter(coordinator: self, pharmaRepository: pharmaRepository)
            let view = PharmaViewController(presenter: presenter)
            view.layout.shouldPinHeaders = false
            return (presenter, view)
        }()

        // Convoluted way to get the dependency in but required for testing
        ifap.0.tracker = tracker
        pocketCard.0.tracker = tracker

        let presenter = PharmaPagePresenter(
            coordinator: self,
            pharmaRepository: pharmaRepository,
            pharmaCardDeepLink: pharmaCardDeepLink,
            snippetRepository: snippetRepository,
            tracker: tracker,
            ifap: ifap,
            pocketCard: pocketCard)
        return presenter
    }
}

extension PharmaCoordinator: SnippetLearningCardDisplayer {
    func navigate(to deeplink: LearningCardDeeplink, shouldPopToRoot: Bool) {
        rootCoordinator.navigate(to: .learningCard(deeplink))
    }
}

extension PharmaCoordinator: PDFViewerCoordinatorType {

    func shareDocument(_ url: URL, with filename: String) {
        let shareableFileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? FileManager.default.copyItem(at: url, to: shareableFileUrl)

        let activityController = UIActivityViewController(activityItems: [shareableFileUrl], applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, _, _, _ in
            if activity == nil {
                try? FileManager.default.removeItem(at: shareableFileUrl)
            }
        }

        // WORKAROUND: On ipad, activity controller is shown near share button as a popover. In order to provide its button we needed to either pass the button or grab it from UINavigationController. Passing it from presenter to coordinator was breaking our architecture. We choose to grab the button from UINavigationController with a hacky way.
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityController.popoverPresentationController?.barButtonItem = (navigationController.presentedViewController as? UINavigationController)?.viewControllers.first?.navigationItem.rightBarButtonItem
        }

        pdfNavigationController?.present(activityController, animated: true)
    }
}
