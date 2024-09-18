//
//  MiniMapPresenter.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 01.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

protocol MiniMapPresenterType: AnyObject {
    var view: MiniMapViewType? { get set }
    func didSelectItem(_ item: MiniMapViewItem)
}

final class MiniMapPresenter: MiniMapPresenterType {

    weak var view: MiniMapViewType? {
        didSet {
            getLearningCardMetaItem()
        }
    }

    private let learningCardIdentifier: LearningCardIdentifier
    private let coordinator: LearningCardCoordinatorType
    private let libraryRepository: LibraryRepositoryType
    private let currentModes: [String]
    @Inject private var monitor: Monitoring

    init(learningCardIdentifier: LearningCardIdentifier, coordinator: LearningCardCoordinatorType, libraryRepository: LibraryRepositoryType = resolve(), currentModes: [String]) {
        self.learningCardIdentifier = learningCardIdentifier
        self.coordinator = coordinator
        self.libraryRepository = libraryRepository
        self.currentModes = currentModes
    }

    private func getLearningCardMetaItem() {
        guard let learningCardMetaItem = try? libraryRepository.library.learningCardMetaItem(for: learningCardIdentifier) else {
            return monitor.debug("Could not load learning card meta item", context: .library)
        }

        let filteredMiniMapNodes = filterMinimapNodes(learningCardMetaItem.minimapNodes, currentModes: currentModes)
        view?.set(items: convert(filteredMiniMapNodes))
    }

    func didSelectItem(_ item: MiniMapViewItem) {
        coordinator.navigate(to: LearningCardDeeplink(learningCard: learningCardIdentifier, anchor: LearningCardAnchorIdentifier(value: item.miniMapNode.anchor.value), particle: nil, sourceAnchor: nil), snippetAllowed: false)
        coordinator.dismissMiniMapView()
    }

    private func filterMinimapNodes(_ minimapNodes: [MinimapNodeMeta], currentModes: [String]) -> [MinimapNodeMeta] {
        minimapNodes.compactMap { node in
            guard Set(node.requiredModes).isSubset(of: currentModes) else { return nil }

            let filteredChildNodes = filterMinimapNodes(node.childNodes, currentModes: currentModes)
            return MinimapNodeMeta(title: node.title, anchor: node.anchor, childNodes: filteredChildNodes, requiredModes: node.requiredModes)
        }
    }

    private func convert(_ minimapNodes: [MinimapNodeMeta]) -> [MiniMapViewItem] {
        var miniMapViewItem = [MiniMapViewItem]()
        minimapNodes.forEach { node in
            miniMapViewItem.append(MiniMapViewItem(miniMapNode: node, itemType: .parent))
            miniMapViewItem.append(contentsOf: node.childNodes.map { MiniMapViewItem(miniMapNode: $0, itemType: .child) })
        }
        return miniMapViewItem
    }
}
