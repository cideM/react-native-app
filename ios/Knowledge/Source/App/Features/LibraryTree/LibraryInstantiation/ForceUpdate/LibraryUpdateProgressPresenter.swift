//
//  LibraryUpdateProgressPresenter.swift
//  Knowledge
//
//  Created by Silvio Bulla on 15.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

protocol LibraryUpdateProgressPresenterType: AnyObject {
    var view: ForceLibraryUpdateViewType? { get set }
}

final class LibraryUpdateProgressPresenter: LibraryUpdateProgressPresenterType {

    let coordinator: LibraryInstantiationCoordinatorType
    let libraryUpdater: LibraryUpdaterType
    var libraryUpdateStateDidChangeObserver: NSObjectProtocol?

    init(coordinator: LibraryInstantiationCoordinator, libraryUpdater: LibraryUpdaterType) {
        self.coordinator = coordinator
        self.libraryUpdater = libraryUpdater
        libraryUpdateStateDidChangeObserver = NotificationCenter.default.observe(for: LibraryUpdaterStateDidChangeNotification.self, object: libraryUpdater, queue: .main) { [weak self] _ in
            self?.updateView()
        }
    }

    weak var view: ForceLibraryUpdateViewType? {
        didSet {
            updateView()
        }
    }

    func updateView() {
        guard let view = view else { return }
        switch libraryUpdater.state {
        case .checking: view.setUpdating(0)
        case .downloading(_, let progress, _): view.setUpdating(progress)
        case .installing: view.setInstalling()
        case .failed(_, let error):
            let retry = MessageAction(title: L10n.Generic.retry, style: .primary) { [weak self] in
                self?.libraryUpdater.initiateUpdate(isUserTriggered: true)
                return true
            }
            view.setFailed(with: error, actions: [retry])
        case .upToDate:
            coordinator.finishForceUpdate()
        }
    }

}
