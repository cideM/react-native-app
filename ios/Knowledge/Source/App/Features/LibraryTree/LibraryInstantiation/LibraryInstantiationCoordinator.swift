//
//  LibraryInstantiationCoordinator.swift
//  Knowledge
//
//  Created by CSH on 17.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import UIKit

/// @mockable
protocol LibraryInstantiationCoordinatorType: Coordinator {
    func finishInitialization(repository: LibraryRepositoryType)
    func finishForceUpdate()
}

final class LibraryInstantiationCoordinator: LibraryInstantiationCoordinatorType {

    var rootNavigationController: UINavigationController {
        navigationController.navigationController
    }

    private let navigationController: SectionedNavigationController
    private let nextCoordinatorFactory: () -> (Coordinator)
    private let libraryUpdater: LibraryUpdateApplicationServiceType
    private let storage: Storage
    private var state: State = .uninitialized {
        didSet {
            switch state {
            case .uninitialized:
                libraryUpdateStateDidChangeObserver = nil
                showInitialization()
            case .updateRequired:
                libraryUpdateStateDidChangeObserver = nil
                showUpdating()
            case .initialized(let libraryRepository):
                libraryUpdateStateDidChangeObserver = NotificationCenter.default.observe(for: LibraryUpdaterStateDidChangeNotification.self, object: libraryUpdater, queue: .main) { [weak self] change in
                    switch change.newValue {
                    case .downloading(let update, _, _) where update.updateMode == .must,
                         .installing(let update, _) where update.updateMode == .must,
                         .failed(let update, _) where update.updateMode == .must:
                        self?.stop(animated: false)
                        self?.storage.uninstalledMustUpdate = update
                        self?.state = .updateRequired
                    default: break
                    }
                }
                showNext(libraryRepository: libraryRepository)
            }
        }
    }

    private var libraryUpdateStateDidChangeObserver: NSObjectProtocol?
    private var nextCoordinator: Coordinator?

    init(_ navigationController: UINavigationController, libraryUpdater: LibraryUpdateApplicationServiceType = resolve(), storage: Storage = resolve(tag: .default), nextCoordinatorFactory: @escaping () -> (Coordinator)) {
        self.navigationController = SectionedNavigationController(navigationController)
        self.nextCoordinatorFactory = nextCoordinatorFactory
        self.libraryUpdater = libraryUpdater
        self.storage = storage
    }

    func start(animated: Bool) {
        switch state {
        case .uninitialized: showInitialization()
        case .initialized(let libraryRepository): showNext(libraryRepository: libraryRepository)
        case .updateRequired: showUpdating()
        }
    }

    func stop(animated: Bool) {
        nextCoordinator?.stop(animated: animated)
    }

    private weak var initializationViewController: UIViewController?
    private func showInitialization() {
        let presenter = InitialLibraryInstantiationPresenter(coordinator: self, libraryUpdater: libraryUpdater)
        let viewController = InitialLibraryInstantiationViewController(presenter: presenter)
        viewController.modalPresentationStyle = .fullScreen
        initializationViewController = viewController

        navigationController.pushViewController(viewController, animated: false)

        // If the initialization is so fast, that it finished while presenting, we want to dismiss it straight away
        switch state {
        case .updateRequired, .initialized:

            navigationController.popToRoot(animated: false)
        case .uninitialized: break
        }
    }
    func finishForceUpdate() {
        finishForceUpdate(libraryRepository: resolve())
    }
    func finishInitialization(repository: LibraryRepositoryType) {
        navigationController.popToRoot(animated: false)
        if self.storage.uninstalledMustUpdate != nil {
            self.state = .updateRequired
        } else {
            self.state = .initialized(libraryRepository: repository)
        }
    }

    private weak var forceUpdateViewController: UIViewController?
    private func showUpdating() {
        libraryUpdater.initiateUpdate(isUserTriggered: false) // starts the update if it isn't already running
        let presenter = LibraryUpdateProgressPresenter(coordinator: self, libraryUpdater: self.libraryUpdater)
        let viewController = LibraryUpdateProgressViewController(presenter: presenter)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(viewController, animated: false)
        forceUpdateViewController = viewController
    }

    func finishForceUpdate(libraryRepository: LibraryRepositoryType = resolve()) {
        navigationController.popToRoot(animated: false)
        self.storage.uninstalledMustUpdate = nil
        self.state = .initialized(libraryRepository: libraryRepository)
    }

    private func showNext(libraryRepository: LibraryRepositoryType) {
        self.nextCoordinator = self.nextCoordinatorFactory()
        self.nextCoordinator?.start(animated: false)
    }
}

extension LibraryInstantiationCoordinator {
    enum State {
        /// Repository needs initialization
        case uninitialized
        /// Repository is initialized and no force update required
        case initialized(libraryRepository: LibraryRepositoryType)
        /// Repository is initialized and force update required
        case updateRequired
    }
}

extension Storage {
    var uninstalledMustUpdate: LibraryUpdate? {
        get {
            get(for: .requiredMustUpdate)
        }
        set {
            store(newValue, for: .requiredMustUpdate)
        }
    }
}
