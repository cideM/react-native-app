//
//  ExtensionPresenter.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 17.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

protocol ExtensionPresenterType: AnyObject {
    var view: ExtensionViewType? { get set }
    func deepLink(to learningCard: LearningCardDeeplink)
}

final class ExtensionPresenter: ExtensionPresenterType {

    weak var view: ExtensionViewType? {
        didSet {
            view?.setExtensions(extensionViewData())
        }
    }

    private let extensionRepository: ExtensionRepositoryType
    private let libraryRepository: LibraryRepositoryType
    private let coordinator: ListCoordinatorType
    private var extensionsDidChangeObserver: NSObjectProtocol?
    private let trackingProvider: TrackingType

    init(extensionRepository: ExtensionRepositoryType = resolve(), libraryRepository: LibraryRepositoryType = resolve(), coordinator: ListCoordinatorType, trackingProvider: TrackingType = resolve()) {
        self.extensionRepository = extensionRepository
        self.libraryRepository = libraryRepository
        self.coordinator = coordinator
        self.trackingProvider = trackingProvider

        extensionsDidChangeObserver = NotificationCenter.default.observe(for: ExtensionsDidChangeNotification.self, object: extensionRepository, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.view?.setExtensions(self.extensionViewData())
        }
    }

    private func extensionViewData() -> [ExtensionViewData] {
        extensionRepository.extensionsMetaData()
            .filter { !$0.isEmptyNote }
            .sorted { $0.updatedAt > $1.updatedAt }
            .map { [extensionRepository, libraryRepository] metadata in
                ExtensionViewData(extensionFactory: {
                    extensionRepository.extensionForSection(metadata.section)
                }, learningCardFactory: {
                    try? libraryRepository.library.learningCardMetaItem(for: metadata.learningCard)
                })
            }
    }

    func deepLink(to learningCard: LearningCardDeeplink) {
        coordinator.navigate(to: learningCard)
        trackingProvider.track(.articleSelected(articleID: learningCard.learningCard.value, referrer: .ownExtensions))
    }
}
