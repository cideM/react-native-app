//
//  ListsCoordinator.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 25.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import UIKit

/// @mockable
protocol ListsCoordinatorType: Coordinator {
    func openFavourites()
    func openLearned()
    func openRecents()
    func openNotes()
}

final class ListsCoordinator: ListsCoordinatorType {

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private var listsViewController: ListsViewController?
    private var listsPresenter: ListsPresenter?
    private let navigationController: SectionedNavigationController
    private let rootCoordinator: RootCoordinatorType

    init(
        _ navigationController: UINavigationController,
        rootCoordinator: RootCoordinatorType
    ) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.rootCoordinator = rootCoordinator
    }

    func openFavourites() {
        presentListView(for: .favorite, selected: .favourites)
    }

    func openLearned() {
        presentListView(for: .learned, selected: .learned)
    }

    func openRecents() {
        presentListView(for: .opened, selected: .recents)
    }

    func openNotes() {
        let presenter = ExtensionPresenter(coordinator: self)
        let viewController = ExtensionListViewController(presenter: presenter)
        listsViewController?.set(viewController)
        listsViewController?.select(.notes)
    }

    func start(animated: Bool) {
        let listsPresenter = ListsPresenter(coordinator: self)
        let listsViewController = ListsViewController(presenter: listsPresenter)
        navigationController.pushViewController(listsViewController, animated: true)
        listsViewController.setItems([.recents, .favourites, .learned, .notes])
        self.listsViewController = listsViewController
        self.listsPresenter = listsPresenter
        openRecents()
    }

    func stop(animated: Bool) {
        navigationController.popToRoot(animated: true)
    }

    private func presentListView(for tag: Tag, selected list: List) {
        let presenter = ListPresenter(coordinator: self, tag: tag, trackingProvider: ListTracker())
        let viewController = ListViewController(presenter: presenter)
        listsViewController?.set(viewController)
        listsViewController?.select(list)
    }
}

extension ListsCoordinator: ListCoordinatorType {
    func navigate(to learningCard: LearningCardDeeplink) {
        rootCoordinator.navigate(to: .learningCard(learningCard))
    }
}
