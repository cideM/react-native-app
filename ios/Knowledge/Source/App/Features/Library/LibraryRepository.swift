//
//  LibraryRepository.swift
//  Knowledge
//
//  Created by CSH on 17.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain

final class LibraryRepository: LibraryRepositoryType {

    let learningCardStack = PointableStack<LearningCardDeeplink>()

    var library: LibraryType {
        willSet {
            assert(Thread.isMainThread, "Only set this on the main thread")
            assert(newValue.url.absoluteString.hasPrefix(baseFolder.absoluteString), "Move the library to the correct folder first")
            storage.store(newValue.url.lastPathComponent, for: .libraryFolderName)
        }
        didSet {
            NotificationCenter.default.post(LibraryDidChangeNotification(oldValue: oldValue, newValue: library), sender: self)
        }
    }
    private let storage: Storage
    private let baseFolder: URL

    private var monitor: Monitoring

    private init(library: LibraryType, storage: Storage = resolve(tag: .default), baseFolder: URL = resolve(tag: .libraryRoot), monitor: Monitoring = resolve()) {
        self.storage = storage
        self.baseFolder = baseFolder
        self.monitor = monitor
        self.library = library
        NotificationCenter.default.post(LibraryRepositoryDidInitializeNotification(libraryRepository: self), sender: self)
    }

    convenience init(storage: Storage = resolve(tag: .default), baseFolder: URL = resolve(tag: .libraryRoot), monitor: Monitoring = resolve()) {
        let library = Library.fromPreparedArchive() ?? Library.fromInstalledArchive() ?? Library.fromPartialArchive()
        self.init(library: library, storage: storage, baseFolder: baseFolder, monitor: monitor)
    }

    func itemsForParent(_ parent: LearningCardTreeItem?) -> [LearningCardTreeItem] {
        library.learningCardTreeItems.filter { $0.parent == parent?.id }
    }

    func itemForLearningCardIdentifier(_ learningCardIdentifiers: LearningCardIdentifier) -> LearningCardTreeItem? {
        library.learningCardTreeItems.first { $0.learningCardIdentifier == learningCardIdentifiers }
    }
}

fileprivate extension Library {
    static func fromPartialArchive(partialArchiveUrl: URL = resolve(tag: .partialArchive)) -> Library {
        do {
            return try Library(with: partialArchiveUrl)
        } catch {
            fatalError("Failed to initialize library from partial archive with error: \(error)")
        }
    }
    static func fromPreparedArchive(storage: Storage = resolve(tag: .default), baseFolder: URL = resolve(tag: .libraryRoot), monitor: Monitoring = resolve()) -> Library? {
        guard let preparedLibraryFolder: String = storage.get(for: .preparedLibraryFolderName) else { return nil }
        return try? Library(with: baseFolder.appendingPathComponent(preparedLibraryFolder))
    }
    static func fromInstalledArchive(storage: Storage = resolve(tag: .default), baseFolder: URL = resolve(tag: .libraryRoot), monitor: Monitoring = resolve()) -> Library? {
        guard let installedLibraryFolder: String = storage.get(for: .libraryFolderName) else { return nil }
        return try? Library(with: baseFolder.appendingPathComponent(installedLibraryFolder))
    }
}
