//
//  ListsViewController.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 26.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import UIKit
import Localization

/// @mockable
protocol ListsViewType: AnyObject {
    func setItems(_ items: [List])
    func select(_ item: List)
}

final class ListsViewController: SegementedControlSectionedViewController, ListsViewType {

    let presenter: ListsPresenterType
    private var lists: [List] = [] {
        didSet {
            self.images = lists.map { self.image(for: $0) }
        }
    }

    init(presenter: ListsPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        title = L10n.Lists.title
        tabBarItem.image = Asset.Icon.bookmark.image
        view.backgroundColor = ThemeManager.currentTheme.textBackgroundColor
    }

    func setItems(_ items: [List]) {
        lists = items
    }

    func select(_ item: List) {
        guard let index = lists.firstIndex(of: item) else { return }
        setSelectedItem(index)
        navigationItem.title = string(for: item)
    }

    override func didSelectItem(at index: Int) {
        guard index < lists.count else { return }
        presenter.goToItem(lists[index])
    }

    private func image(for item: List) -> UIImage {
        switch item {
        case .favourites: return Asset.Icon.Lists.favorite.image
        case .learned: return Asset.Icon.Lists.learned.image
        case .recents: return Asset.Icon.Lists.recent.image
        case .notes: return Asset.Icon.Lists.notes.image
        }
    }

    private func string(for list: List) -> String {
        switch list {
        case .favourites: return L10n.Lists.Favorites.title
        case .recents: return L10n.Lists.Recents.title
        case .learned: return L10n.Lists.Learned.title
        case .notes: return L10n.ExtensionView.title
        }
    }
}
