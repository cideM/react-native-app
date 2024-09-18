//
//  SnippetRepository.swift
//  Knowledge
//
//  Created by Silvio Bulla on 12.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

/// @mockable
protocol SnippetRepositoryType {
    func snippet(for learningCardDeeplink: LearningCardDeeplink) throws -> Snippet?
    func snippet(for identifier: SnippetIdentifier, completion: @escaping (Result<Snippet, NetworkError<EmptyAPIError>>) -> Void)
}

final class SnippetRepository: SnippetRepositoryType {

    private let libraryRepository: LibraryRepositoryType
    private let snippetClient: SnippetClient

    init(libraryRepository: LibraryRepositoryType = resolve(), snippetClient: SnippetClient = resolve()) {
        self.libraryRepository = libraryRepository
        self.snippetClient = snippetClient
    }

    func snippet(for learningCardDeeplink: LearningCardDeeplink) throws -> Snippet? {
        try libraryRepository.library.snippet(for: learningCardDeeplink)
    }

    func snippet(for identifier: SnippetIdentifier, completion: @escaping (Result<Snippet, NetworkError<EmptyAPIError>>) -> Void) {
        guard let snippet = try? libraryRepository.library.snippet(withIdentifier: identifier) else {
            return snippetClient.getSnippet(for: identifier, cachePolicy: .returnCacheDataElseLoad) { result in
                switch result {
                case .success(let snippet):
                    completion(.success(snippet))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        completion(.success(snippet))
    }
}
