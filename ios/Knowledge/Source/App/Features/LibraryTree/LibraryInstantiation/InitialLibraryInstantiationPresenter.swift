//
//  InitialLibraryInstantiationPresenter.swift
//  Knowledge
//
//  Created by CSH on 24.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

protocol InitialLibraryInstantiationPresenterType: AnyObject {
    var view: InitialLibraryInstantiationViewType? { get set }
}

final class InitialLibraryInstantiationPresenter: InitialLibraryInstantiationPresenterType {

    weak var view: InitialLibraryInstantiationViewType? {
        didSet {
            let repository: LibraryRepositoryType = resolve()
            coordinator.finishInitialization(repository: repository)
        }
    }

    private let coordinator: LibraryInstantiationCoordinatorType
    private let libraryUpdater: LibraryUpdateApplicationServiceType

    init(coordinator: LibraryInstantiationCoordinatorType, libraryUpdater: LibraryUpdateApplicationServiceType) {
        self.coordinator = coordinator
        self.libraryUpdater = libraryUpdater
    }
}
