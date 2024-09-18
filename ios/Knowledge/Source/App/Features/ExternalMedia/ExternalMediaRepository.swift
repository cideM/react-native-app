//
//  ExternalMediaRepository.swift
//  Knowledge
//
//  Created by CSH on 17.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

/// @mockable
protocol ExternalMediaRepositoryType: AnyObject {
    func getExternalAddition(for externalAdditionId: ExternalAdditionIdentifier, completion: @escaping (Result<ExternalAddition, Error>) -> Void)
}

final class ExternalMediaRepository: ExternalMediaRepositoryType {
    private let mediaClient: MediaClient

    init(mediaClient: MediaClient = resolve()) {
        self.mediaClient = mediaClient
    }

    func getExternalAddition(for externalAdditionId: ExternalAdditionIdentifier, completion: @escaping (Result<ExternalAddition, Error>) -> Void) {
        mediaClient.getExternalAddition(externalAdditionId) { result in
            switch result {
            case .success(let externalAddition): completion(.success(externalAddition))
            case .failure(let error): completion(.failure(error))
            }
        }
    }
}
