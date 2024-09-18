//
//  LibraryDownloadStatePresenter.swift
//  Knowledge
//
//  Created by CSH on 22.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

protocol LibraryDownloadStatePresenterType: AnyObject {
    var view: LibraryDownloadStateViewType? { get set }
}

final class LibraryDownloadStatePresenter: LibraryDownloadStatePresenterType {

    private let libraryUpdater: LibraryUpdaterType
    private var libraryUpdaterStateDidChangeObserver: NSObjectProtocol?

    weak var view: LibraryDownloadStateViewType? {
        didSet {
            updateView()
        }
    }

    init(libraryUpdater: LibraryUpdaterType) {
        self.libraryUpdater = libraryUpdater
        libraryUpdaterStateDidChangeObserver = NotificationCenter.default.observe(for: LibraryUpdaterStateDidChangeNotification.self, object: libraryUpdater, queue: .main) { [weak self] _ in
            self?.updateView()
        }
    }

    private func updateView() {
        guard let view = view else { return }
        switch libraryUpdater.state {
        case .upToDate, .checking: view.setIsUpToDate()
        case .downloading, .installing: break
        case .failed: view.setIsFailed()
        }
    }
}
