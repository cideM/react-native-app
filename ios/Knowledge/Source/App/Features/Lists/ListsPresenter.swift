//
//  ListsPresenter.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 26.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

protocol ListsPresenterType: AnyObject {
    var view: ListsViewType? { get set }
    func goToItem(_ item: List)
    func select(_ item: List)
}

final class ListsPresenter: ListsPresenterType {

    weak var view: ListsViewType?
    private let coordinator: ListsCoordinatorType

    init(coordinator: ListsCoordinatorType) {
        self.coordinator = coordinator
    }

    func goToItem(_ item: List) {
        switch item {
        case .favourites: coordinator.openFavourites()
        case .learned: coordinator.openLearned()
        case .recents: coordinator.openRecents()
        case .notes: coordinator.openNotes()
        }
    }

    func select(_ item: List) {
        view?.select(item)
    }
}
