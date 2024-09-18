//
//  LibraryDownloadStateErrorPresenter.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 29.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import Localization

protocol LibraryDownloadStateErrorPresenterType: AnyObject {
    var messagePresenter: MessagePresenter? { get set }
}

final class LibraryDownloadStateErrorPresenter: LibraryDownloadStateErrorPresenterType {
    weak var messagePresenter: MessagePresenter?

    private var lastKnownRecommendedUpdateVersion: Int? {
        get {
            storage.get(for: .lastKnownRecommendedUpdateVersion)
        }
        set {
            storage.store(newValue, for: .lastKnownRecommendedUpdateVersion)
        }
    }

    private let libraryUpdater: LibraryUpdaterType
    private let storage: Storage
    private var libraryUpdaterStateDidChangeObserver: NSObjectProtocol?
    private var lastState: LibraryUpdaterState

    init(libraryUpdater: LibraryUpdaterType = resolve(), storage: Storage = resolve(tag: .default)) {
        self.libraryUpdater = libraryUpdater
        self.storage = storage
        self.lastState = libraryUpdater.state

        libraryUpdaterStateDidChangeObserver = NotificationCenter.default.observe(for: LibraryUpdaterStateDidChangeNotification.self, object: libraryUpdater, queue: .main) { [weak self] _ in
            self?.stateDidChange()
        }
    }

    private func stateDidChange() {
        defer {
            lastState = libraryUpdater.state
        }

        switch (lastState, libraryUpdater.state) {
        case (.downloading(_, _, true), .failed(_, let libraryUpdateError)):
            messagePresenter?.present(libraryUpdateError, actions: [.dismiss])
        case (_, .failed(let libraryUpdate, _)) where libraryUpdate.updateMode == .should:
            presentRecommendedUpdateMessage(for: libraryUpdate.version)
        default: break
        }
    }

    private func presentRecommendedUpdateMessage(for version: Int) {
        guard lastKnownRecommendedUpdateVersion != version else { return }

        let downloadAction = MessageAction(title: L10n.RecommendUpdate.Alert.downloadAction, style: .normal) { [weak self] in
            self?.libraryUpdater.initiateUpdate(isUserTriggered: true)
            self?.lastKnownRecommendedUpdateVersion = version
            return true
        }
        let laterAction = MessageAction(title: L10n.RecommendUpdate.Alert.laterAction, style: .normal) { [weak self] in
            self?.lastKnownRecommendedUpdateVersion = version
            return true
        }
        let message = PresentableMessage(title: L10n.RecommendUpdate.Alert.title, description: L10n.RecommendUpdate.Alert.message, logLevel: .warning)

        messagePresenter?.present(message, actions: [downloadAction, laterAction])
    }

}
