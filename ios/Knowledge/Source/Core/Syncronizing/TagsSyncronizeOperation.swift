//
//  TagsSyncronizeOperation.swift
//  Knowledge
//
//  Created by CSH on 12.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation
import Networking

/// Note: This is just a proof of concept for now and shows how some user data can be syncronized. This is not tested and shold not be expected to work.
private final class TagsSyncronizeOperation: SucceedableSequentialOperation {

    init(tagRepository: TagRepository, learningCardClient: LearningCardLibraryClient, lastSyncronization: Date?) {
        let uploadOperation = TagsUploadOperation(tagRepository: tagRepository, learningCardClient: learningCardClient, lastSyncronization: lastSyncronization)
        let downloadOperation = TagsDownloadOperation(tagRepository: tagRepository, learningCardClient: learningCardClient, lastSyncronization: lastSyncronization)
        super.init(operations: [uploadOperation, downloadOperation])
    }
}

private class TagsUploadOperation: SucceedableOperation {

    private let tagRepository: TagRepository
    private let learningCardClient: LearningCardLibraryClient
    private let lastSyncronization: Date?

    init(tagRepository: TagRepository, learningCardClient: LearningCardLibraryClient, lastSyncronization: Date?) {
        self.tagRepository = tagRepository
        self.learningCardClient = learningCardClient
        self.lastSyncronization = lastSyncronization
    }

    override func execute(completion: @escaping (Result<Void, Error>) -> Void) {
        let localChangesSinceLastSyncronization = tagRepository.taggings(changedSince: lastSyncronization, tags: [.favorite, .learned])

        learningCardClient.uploadTaggings(localChangesSinceLastSyncronization) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                completion(.success(()))
            }
        }
    }
}

private class TagsDownloadOperation: SucceedableOperation {

    private let tagRepository: TagRepository
    private let learningCardClient: LearningCardLibraryClient
    private let lastSyncronization: Date?

    init(tagRepository: TagRepository, learningCardClient: LearningCardLibraryClient, lastSyncronization: Date?) {
        self.tagRepository = tagRepository
        self.learningCardClient = learningCardClient
        self.lastSyncronization = lastSyncronization
    }

    override func execute(completion: @escaping (Result<Void, Error>) -> Void) {
        learningCardClient.getTaggings(after: nil) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let taggings):
                self.tagRepository.addTags(taggings?.elements ?? [])
                completion(.success(()))
            }
        }
    }
}
