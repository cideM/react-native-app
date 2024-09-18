//
//  AccessRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 27.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

/// @mockable
protocol AccessRepositoryType: AnyObject {
    /// Persists the target accesses in the local storage.
    /// This method replaces the previously stored accesses.
    /// - Parameter accesses: The accesses to persist.
    func set(accesses: [TargetAccess])

    /// Gets the access for a certain target.
    ///
    /// When the locally stored access for a target is `denied`, this method tries to fetch the latest access value for that target from the server and updates the locally stored accesses array then returns the latest access for that target regardless from its value.
    /// - Parameters:
    ///   - target: The target to check its access.
    ///   - completion: A completion block that's called with a `Result` type instance that will contain either success or failure with specific access error.
    func getAccess(for target: AccessTarget, completion: @escaping (Result<Void, AccessError>) -> Void)

    /// Gets the access for a specific learning card.
    /// - Parameters:
    ///   - learningCard: The learning card to check its acces.
    ///   - completion: A completion block that's called with a `Result` type instance that will contain either success or failure with specific access error.
    func getAccess(for learningCard: LearningCardMetaItem, completion: @escaping (Result<Void, AccessError>) -> Void)

    /// Gets the access  for a specific feature
    /// - Parameters:
    ///   - externalAddition: The external addition used to check its access
    ///   - completion: A completion block that's called with a `Result` type instance that will contain either success or failure with specific access error.
    func getAccess(for externalAddition: ExternalAddition, completion: @escaping (Result<Void, AccessError>) -> Void)

    /// Removes all the stored accesses from the local storage.
    func removeAllDataFromLocalStorage()
}

final class AccessRepository: AccessRepositoryType {
    private let learningCardClient: LearningCardLibraryClient
    private let storage: Storage
    private var accesses: [TargetAccess] {
        get {
            storage.get(for: .accesses) ?? []
        }
        set {
            storage.store(newValue, for: .accesses)
        }
    }

    init(learningCardClient: LearningCardLibraryClient = resolve(), storage: Storage) {
        self.learningCardClient = learningCardClient
        self.storage = storage
    }

    func set(accesses: [TargetAccess]) {
        self.accesses = accesses
    }

    func getAccess(for target: AccessTarget, completion: @escaping (Result<Void, AccessError>) -> Void) {
        let getAccessResult = accesses.access(for: target)?.getAccess(at: Date())
        switch getAccessResult {
        case .success: completion(.success(()))
        default:
            learningCardClient.getTargetAccesses { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let accesses):
                    self.accesses = accesses
                    let getAccessResult = accesses.access(for: target)?.getAccess(at: Date())
                    completion(getAccessResult ?? .failure(.unknown("Access for target not found")))
                case .failure(let error):
                    switch error {
                    case .noInternetConnection, .requestTimedOut:
                        completion(.failure(.offlineAccessExpired))
                    default:
                        completion(.failure(.unknown("Error could not be updated from the server: \(error)")))
                    }
                }
            }
        }
    }

    func getAccess(for learningCard: LearningCardMetaItem, completion: @escaping (Result<Void, AccessError>) -> Void) {
        if learningCard.alwaysFree {
            completion(.success(()))
        } else {
            getAccess(for: AccessTargets.learningCard, completion: completion)
        }
    }

    func removeAllDataFromLocalStorage() {
        storage.store(nil as [TargetAccess]?, for: .accesses)
    }

    func getAccess(for externalAddition: ExternalAddition, completion: @escaping (Result<Void, AccessError>) -> Void) {
        // WORKAROUND: The backend doesnt have an access type for video at the moment,
        // so all video permision checks would fail, so we allow access for type video

        guard !externalAddition.isFree, externalAddition.type != .video else { return completion(.success(())) }

        let target = AccessTarget(value: externalAddition.type.rawValue)
        getAccess(for: target, completion: completion)
    }
}

extension Array where Element == TargetAccess {
    func access(for target: AccessTarget) -> Access? {
        first { $0.target == target }?.access
    }
}
