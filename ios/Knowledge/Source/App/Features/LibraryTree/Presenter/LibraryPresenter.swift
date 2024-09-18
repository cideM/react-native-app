//
//  LibraryPresenter.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 9/23/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

final class LibraryPresenter: LibraryPresenterType {

    private let coordinator: LibraryCoordinatorType
    private let parent: LearningCardTreeItem?
    private let trackingProvider: TrackingType
    private let tagRepository: TagRepositoryType

    private var libraryDidUpdateObserver: NSObjectProtocol?
    private var taggingsDidChangeObserver: NSObjectProtocol?

    private var libraryRepository: LibraryRepositoryType {
        didSet {
            loadLibraryRepositoryData()
        }
    }

    weak var view: LibraryViewType? {
        didSet {
            view?.setTitle(parent?.title ?? L10n.Library.title)
            loadLibraryRepositoryData()
        }
    }

    init(coordinator: LibraryCoordinatorType, libraryRepository: LibraryRepositoryType = resolve(), trackingProvider: TrackingType = resolve(), parent: LearningCardTreeItem? = nil, tagRepository: TagRepositoryType = resolve()) {
        self.coordinator = coordinator
        self.libraryRepository = libraryRepository
        self.trackingProvider = trackingProvider
        self.parent = parent
        self.tagRepository = tagRepository

        libraryDidUpdateObserver = NotificationCenter.default.observe(for: LibraryDidChangeNotification.self, object: nil, queue: .main) { [weak self] _ in
            self?.loadLibraryRepositoryData()
        }

        taggingsDidChangeObserver = NotificationCenter.default.observe(for: TaggingsDidChangeNotification.self, object: tagRepository, queue: .main) { [weak self] _ in
            self?.loadLibraryRepositoryData()
        }
    }

    func didSelectItem(_ item: LearningCardTreeItem) {
        if let learninCardIdentifier = item.learningCardIdentifier {
            coordinator.goToLearningCardItem(learninCardIdentifier)
            trackingProvider.track(.articleSelected(articleID: learninCardIdentifier.value, referrer: .library))
        } else {
            coordinator.goToLibraryTreeItem(item)
        }
    }

    private func loadLibraryRepositoryData() {
        let items = libraryRepository.itemsForParent(parent)
        view?.setLearningCardTreeItems(items)
    }

    func didSelectSearch() {
        coordinator.showSearchView()
    }
}
