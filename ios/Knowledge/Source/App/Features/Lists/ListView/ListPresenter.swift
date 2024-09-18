//
//  ListPresenter.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 26.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

protocol ListPresenterType: AnyObject {
    var view: ListViewType? { get set }
    func didSelectItem(_ item: LearningCardMetaItem)
}

final class ListPresenter: ListPresenterType {

    weak var view: ListViewType? {
        didSet {
            updateView()
        }
    }

    private func updateView() {
        let tagListViewData = tagListViewData(for: tag)

        if tagListViewData.isEmpty {
            switch tag {
            case .opened:
                view?.setEmptyViewText(L10n.Lists.Recents.EmptyState.text)
            default: break
            }
        } else {
            view?.setTagListViewItems(tagListViewData)
        }
    }

    private let coordinator: ListCoordinatorType
    private let tagRepository: TagRepositoryType
    private let libraryRepository: LibraryRepositoryType
    private let tag: Tag
    private let trackingProvider: ListTrackingProvider
    private let maxNumberOfItems: Int
    private var tagObserver: NSObjectProtocol?

    init(coordinator: ListCoordinatorType, tagRepository: TagRepositoryType = resolve(), libraryRepository: LibraryRepositoryType = resolve(), tag: Tag, trackingProvider: ListTrackingProvider, maxNumberOfItems: Int = .max) {
        self.coordinator = coordinator
        self.tagRepository = tagRepository
        self.libraryRepository = libraryRepository
        self.tag = tag
        self.trackingProvider = trackingProvider
        self.maxNumberOfItems = maxNumberOfItems

        tagObserver = NotificationCenter.default.observe(for: TaggingsDidChangeNotification.self, object: tagRepository, queue: .main) { [weak self] _ in
            self?.updateView()
        }
    }

    private func tagListViewData(for tag: Tag) -> [TagListViewData] {
        switch tag {
        case .favorite, .learned:
            return tagRepository.learningCards(with: tag)
                .prefix(maxNumberOfItems)
                .compactMap { try? libraryRepository.library.learningCardMetaItem(for: $0) }
                .sorted { $0.title < $1.title }
                .map { metaData in TagListViewData { metaData } }
        case .opened:
            return tagRepository.learningCardsSortedByDate(with: tag)
                .prefix(maxNumberOfItems)
                .compactMap { try? libraryRepository.library.learningCardMetaItem(for: $0) }
                .map { metaData in TagListViewData { metaData } }
        }
    }

    func didSelectItem(_ item: LearningCardMetaItem) {
        coordinator.navigate(to: LearningCardDeeplink(learningCard: item.learningCardIdentifier, anchor: nil, particle: nil, sourceAnchor: nil))
        trackingProvider.track(learningCard: item.learningCardIdentifier, tag: tag)
    }
}
