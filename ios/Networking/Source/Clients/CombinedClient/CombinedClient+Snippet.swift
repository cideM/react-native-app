//
//  CombinedClient+Snippet.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 06.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

extension CombinedClient: SnippetClient {
    public func getSnippet(for snippetIdentifier: SnippetIdentifier, cachePolicy: URLRequest.CachePolicy, completion: @escaping Completion<Snippet, NetworkError<EmptyAPIError>>) {
        graphQlClient.getPhraseGroup(
            for: snippetIdentifier.value,
            cachePolicy: cachePolicy,
            completion: postprocess(authorization: self.authorization) { result in
                switch result {
                case .success(let phraseGroup):
                    let snippetDestinations = phraseGroup.destinations.compactMap { destination -> SnippetDestination in
                        var particleID: LearningCardSectionIdentifier?
                        if let particleEid = destination.particleEid {
                            particleID = LearningCardSectionIdentifier(value: particleEid)
                        }
                        return SnippetDestination(articleId: LearningCardIdentifier(value: destination.articleEid), particleEid: particleID, anchor: LearningCardIdentifier(value: destination.anchor), label: destination.label)
                    }
                    let snippet = Snippet(synonyms: phraseGroup.synonyms, title: phraseGroup.title, etymology: phraseGroup.translation, description: phraseGroup.abstract, destinations: snippetDestinations, identifier: snippetIdentifier)
                    completion(.success(snippet))
                case .failure(let error): completion(.failure(error))
                }
            }
        )
    }
}
