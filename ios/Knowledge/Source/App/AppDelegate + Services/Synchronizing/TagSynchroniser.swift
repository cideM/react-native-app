//
//  TagSynchroniser.swift
//  Knowledge
//
//  Created by Silvio Bulla on 23.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain
import Networking

extension TagSynchroniser {
    enum TagSynchroniserError: Error {
        case uploadFailed(Error)
        case downloadFailed(Error)
    }
}

final class TagSynchroniser: Synchronizer {

    private var tagRepository: TagRepositoryType
    private let learningCardClient: LearningCardLibraryClient
    private let storage: Storage
    private let trackingProvider: TrackingType
    @Inject private var monitor: Monitoring
    private var taggingsDidChangeNotificationObserver: NSObjectProtocol?

    private var taggingsEndCursor: PaginationCursor? {
        get {
            storage.get(for: .tagSynchronizerEndCursor)
        }
        set {
            storage.store(newValue, for: .tagSynchronizerEndCursor)
        }
    }

    private var taggingsLastUploadDate: Date? {
        get {
            storage.get(for: .tagSynchronizerLastUploadDate)
        }
        set {
            storage.store(newValue, for: .tagSynchronizerLastUploadDate)
        }
    }

    init(tagRepository: TagRepositoryType = resolve(), learningCardClient: LearningCardLibraryClient = resolve(), storage: Storage = resolve(tag: .default), trackingProvider: TrackingType = resolve()) {
        self.tagRepository = tagRepository
        self.learningCardClient = learningCardClient
        self.storage = storage
        self.trackingProvider = trackingProvider

        taggingsDidChangeNotificationObserver = NotificationCenter.default.observe(for: TaggingsDidChangeNotification.self, object: tagRepository, queue: .main) { [weak self] _ in
            guard let self = self, !self.taggingsToUpload().isEmpty  else { return }
            NotificationCenter.default.post(SynchronizerNeedsSynchronization(synchronizer: self), sender: self)
        }
    }

    func synchronize(_ completion: @escaping (SynchronizationResult) -> Void) {
        monitor.debug("Starting tags synchronisation.", context: .synchronization)

        uploadTaggings { [weak self] uploadResult in
            guard let self = self else { return }

            switch uploadResult {
            case .updated, .notUpdated:
                self.downloadTaggings(.init(self.taggingsEndCursor)) { [weak self] payload, error in
                    // An error might have happened along the way, but we still might have managed to download
                    // one page or the other of taggings, hence try to store that ...
                    self?.store(payload: payload)

                    if let error {
                        self?.monitor.error(TagSynchroniserError.downloadFailed(error), context: .synchronization)
                        completion(.failed)
                    } else {
                        // Neither upload nor download did change any data ...
                        if payload.taggings.isEmpty && uploadResult == .notUpdated {
                            completion(.notUpdated)
                        } else {
                            completion(.updated)
                        }
                    }
                }

            case .failed:
                completion(.failed)
            }
        }
    }

    func removeAllDataFromLocalStorage() {
        taggingsEndCursor = nil
        taggingsLastUploadDate = nil
        tagRepository.removeAllDataFromLocalStorage()
    }

    private func taggingsToUpload() -> [Tagging] {
        tagRepository.taggings(changedSince: taggingsLastUploadDate, tags: [.learned, .favorite])
    }

}

private extension TagSynchroniser {

    func uploadTaggings(_ completion: @escaping (SynchronizationResult) -> Void) {
        let taggings = taggingsToUpload()
        guard !taggings.isEmpty else { completion(.notUpdated); return }

        let taggingsChunks = taggings.chunked(into: 50)
        let uploadStartDate = Date()

        uploadTaggings(chunks: taggingsChunks) { [weak self] result in
            switch result {
            case .success:
                self?.taggingsLastUploadDate = uploadStartDate
                completion(.updated)
            case .failure:
                completion(.failed)
            }
        }
    }

    func uploadTaggings(chunks: [[Tagging]], _ completion: @escaping(Result<Void, Error>) -> Void) {
        guard let firstChunk = chunks.first else { return completion(.success(())) }

        learningCardClient.uploadTaggings(firstChunk) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.uploadTaggings(chunks: Array(chunks.dropFirst()), completion)
            case .failure(let error):
                self.monitor.error(TagSynchroniserError.uploadFailed(error), context: .synchronization)
                completion(.failure(error))
            }
        }
    }

    func downloadTaggings(_ payload: Payload, _ completion: @escaping (Payload, Error?) -> Void) {

            learningCardClient.getTaggings(after: payload.taggingsEndCursor) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(nil):
                    completion(payload, nil)

                case .success(let page):
                    guard let page = page else { return }
                    let payload = payload.adding(cursor: page.nextPage, with: page.elements)

                    if page.hasNextPage {
                        // Stack overflow (the crash, not the website) does not seem to be a problem here.
                        // Tested it manually without updating the cursor and downloaded 17.000 pages (a 50 taggings) without crash.
                        // This means 850.000 annotations. Would be surprised if any user reaches this count.
                        self.downloadTaggings(payload, completion)
                    } else {
                        completion(payload, nil)
                    }

                case .failure(let error):
                    let error = TagSynchroniserError.downloadFailed(error)
                    completion(payload, error)
                }
            }
        }

    func store(payload: Payload?) {
        if let taggingsEndCursor = payload?.taggingsEndCursor, self.taggingsEndCursor != taggingsEndCursor {
            self.taggingsEndCursor = taggingsEndCursor

            // Only import if the cursor changed ...
            if let taggings = payload?.taggings, !taggings.isEmpty {
                self.tagRepository.addTags(taggings)
            }
        }
    }
}

private extension TagSynchroniser {

    struct Payload {

        let taggingsEndCursor: PaginationCursor?
        let taggings: [Tagging]

        init(_ taggingsEndCursor: PaginationCursor? = nil, taggings: [Tagging] = []) {
            self.taggingsEndCursor = taggingsEndCursor
            self.taggings = taggings
        }

        func adding(cursor: PaginationCursor, with taggings: [Tagging]) -> Payload {
            var combinedTaggings = self.taggings
            combinedTaggings.append(contentsOf: taggings)
            return .init(cursor, taggings: combinedTaggings)
        }
    }

}
