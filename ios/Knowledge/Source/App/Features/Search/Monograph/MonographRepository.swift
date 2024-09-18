//
//  MonographRepository.swift
//  MonographRepository
//
//  Created by Roberto Seidenberg on 03.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import DIKit

import Domain
import Networking
/// @mockable
protocol MonographRepositoryType {
    func monograph(with id: MonographIdentifier, completion: @escaping(Result<Monograph, NetworkError<EmptyAPIError>>) -> Void)
}

final class MonographRepository: MonographRepositoryType {
    private let pharmaClient: PharmaClient

    init(pharmaClient: PharmaClient = resolve()) {
        self.pharmaClient = pharmaClient
    }

    func monograph(with id: MonographIdentifier, completion: @escaping(Result<Monograph, NetworkError<EmptyAPIError>>) -> Void) {
        pharmaClient.getMonograph(for: id) { result in
            switch result {
            case .success(let monograph):
                completion(.success(monograph))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
