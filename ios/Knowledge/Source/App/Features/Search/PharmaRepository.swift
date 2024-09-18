//
//  PharmaRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 07.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

/// @mockable
protocol PharmaRepositoryType {

    var pharmaResultWasDisplayedCount: Int { get set }
    var pharmaDialogWasDisplayedDate: Date { get set }
    var shouldShowPharmaOfflineDialog: Bool { get set }

    // Pharma DE
    func pharmaCard(for substanceIdentifier: SubstanceIdentifier, drugIdentifier: DrugIdentifier?, sorting: PackageSizeSortingOrder, cachePolicy: URLRequest.CachePolicy, completion: @escaping (Result<(PharmaCard, Metrics.Source), NetworkError<EmptyAPIError>>) -> Void)
    func substance(for substanceIdentifier: SubstanceIdentifier, cachePolicy: URLRequest.CachePolicy, completion: @escaping (Result<(Substance, Metrics.Source), NetworkError<EmptyAPIError>>) -> Void)
    func drug(for drugIdentifier: DrugIdentifier, sorting: PackageSizeSortingOrder, completion: @escaping (Result<(Drug, Metrics.Source), NetworkError<EmptyAPIError>>) -> Void)
    func selectPharmaSearchResult()
    func dosage(for dosageIdentifier: DosageIdentifier, completion: @escaping (Result<(Dosage, Metrics.Source), NetworkError<EmptyAPIError>>) -> Void)
}

extension PharmaRepositoryType {
    func substance(for substanceIdentifier: SubstanceIdentifier, completion: @escaping (Result<(Substance, Metrics.Source), NetworkError<EmptyAPIError>>) -> Void) {
        substance(for: substanceIdentifier, cachePolicy: .reloadIgnoringCacheData, completion: completion)
    }
}

final class PharmaRepository: PharmaRepositoryType {

    var pharmaResultWasDisplayedCount: Int {
        get {
            userDefaultsStorage.get(for: .pharmaResultWasDisplayedCount) ?? 0
        }
        set {
            userDefaultsStorage.store(newValue, for: .pharmaResultWasDisplayedCount)
        }
    }

    var pharmaDialogWasDisplayedDate: Date {
        get {
            userDefaultsStorage.get(for: .pharmaDialogWasDisplayedDate) ?? Date.distantPast
        }
        set {
            userDefaultsStorage.store(newValue, for: .pharmaDialogWasDisplayedDate)
        }
    }

    var shouldShowPharmaOfflineDialog: Bool {
        get {
            userDefaultsStorage.get(for: .shouldShowPharmaOfflineDialog) ?? true
        }
        set {
            userDefaultsStorage.store(newValue, for: .shouldShowPharmaOfflineDialog)
        }
    }

    private let userDefaultsStorage: Storage
    private let pharmaClient: PharmaClient
    private var pharmaService: PharmaDatabaseApplicationServiceType?
    private let remoteConfigRepository: RemoteConfigRepositoryType
    private let monitor: Monitoring

    init(pharmaClient: PharmaClient = resolve(), userDefaultsStorage: Storage = resolve(tag: .default), pharmaService: PharmaDatabaseApplicationServiceType? = resolve(), remoteConfigRepository: RemoteConfigRepositoryType = resolve(), monitor: Monitoring = resolve()) {
        self.pharmaClient = pharmaClient
        self.userDefaultsStorage = userDefaultsStorage
        self.pharmaService = pharmaService
        self.remoteConfigRepository = remoteConfigRepository
        self.monitor = monitor
    }

    func pharmaCard(for substanceIdentifier: SubstanceIdentifier, drugIdentifier: DrugIdentifier?, sorting: PackageSizeSortingOrder, cachePolicy: URLRequest.CachePolicy, completion: @escaping (Result<(PharmaCard, Metrics.Source), NetworkError<EmptyAPIError>>) -> Void) {
        if let drugIdentifier {
            pharmaClient.getPharmaCard(for: substanceIdentifier, drugIdentifier: drugIdentifier, sorting: sorting, timeout: remoteConfigRepository.requestTimeout, cachePolicy: cachePolicy) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let data):
                    completion(.success((data, .online)))
                case .failure(let networkError):
                    if let substance = self.offlineSubstance(for: substanceIdentifier), let drug = self.offlineDrug(for: drugIdentifier, sorting: sorting) {
                        completion(.success((PharmaCard(substance: substance, drug: drug), .offline)))
                    } else {
                        completion(.failure(networkError))
                    }
                }
            }

        // If this case happens, the substance is actually being loaded two times
        // once via the query below and then again via the pharmaCard query above
        // This should be ok though since this method should only be triggered with a null "drugIdentifier"
        // in case the user opened a deeplink that was missing said "drugIdentifier"
        // (which really should not happen too often)
        } else {
            substance(for: substanceIdentifier, cachePolicy: cachePolicy) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let (substance, _)):
                    self.pharmaCard(for: substanceIdentifier, drugIdentifier: substance.basedOn, sorting: sorting, cachePolicy: cachePolicy, completion: completion)
                case .failure(let networkError):
                    completion(.failure(networkError))
                }
            }
        }
    }

    func substance(for substanceIdentifier: SubstanceIdentifier, cachePolicy: URLRequest.CachePolicy, completion: @escaping (Result<(Substance, Metrics.Source), NetworkError<EmptyAPIError>>) -> Void) {
        pharmaClient.getSubstance(for: substanceIdentifier, timeout: remoteConfigRepository.requestTimeout, cachePolicy: cachePolicy) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let substance):
                completion(.success((substance, .online)))
            case .failure(let networkError):
                if let substance = self.offlineSubstance(for: substanceIdentifier) {
                    completion(.success((substance, .offline)))
                } else {
                    completion(.failure(networkError))
                }
            }
        }
    }

    func drug(for drugIdentifier: DrugIdentifier, sorting: PackageSizeSortingOrder, completion: @escaping (Result<(Drug, Metrics.Source), NetworkError<EmptyAPIError>>) -> Void) {
        pharmaClient.getDrug(for: drugIdentifier, sorting: sorting, timeout: remoteConfigRepository.requestTimeout, cachePolicy: .reloadIgnoringLocalCacheData) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let drug):
                completion(.success((drug, .online)))
            case .failure(let networkError):
                if let drug = self.offlineDrug(for: drugIdentifier, sorting: sorting) {
                    completion(.success((drug, .offline)))
                } else {
                    completion(.failure(networkError))
                }
            }
        }
    }

    func selectPharmaSearchResult() {
        pharmaResultWasDisplayedCount += 1
    }

    func dosage(for dosageIdentifier: DosageIdentifier, completion: @escaping (Result<(Dosage, Metrics.Source), NetworkError<EmptyAPIError>>) -> Void) {

        // Setting the timeout here (value is 2 seconds)
        // only if the user has the PharmaDB installed.
        // This way we fallback to offline data faster
        // in case it is available.
        var timeout: TimeInterval?
        if hasOfflineDB() {
            timeout = remoteConfigRepository.requestTimeout
        }

        pharmaClient.getDosage(for: dosageIdentifier, timeout: timeout, cachePolicy: .reloadIgnoringLocalCacheData) { result in
            switch result {
            case .success(let dosage):
                completion(.success((dosage, .online)))
            case .failure(let error):
                if let dosage = self.offlineDosage(for: dosageIdentifier) {
                    completion(.success((dosage, .offline)))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}

private extension PharmaRepository {

    func hasOfflineDB() -> Bool {
        pharmaService?.pharmaDatabase != nil
    }

    func offlineSubstance(for identifier: SubstanceIdentifier) -> Substance? {
        if let database = pharmaService?.pharmaDatabase {
            do {
                return try database.substance(for: identifier)
            } catch {
                monitor.error(error, context: .pharma)
                return nil
            }
        } else {
            return nil
        }
    }

    func offlineDrug(for identifier: DrugIdentifier, sorting: PackageSizeSortingOrder) -> Drug? {
        if let database = pharmaService?.pharmaDatabase {
            do {
                return try database.drug(for: identifier, sorting: sorting)
            } catch {
                monitor.error(error, context: .pharma)
                return nil
            }
        } else {
            return nil
        }
    }

    func offlineDosage(for identifier: DosageIdentifier) -> Dosage? {
        if let database = pharmaService?.pharmaDatabase {
            do {
                return try database.dosage(for: identifier)
            } catch {
                monitor.error(error, context: .pharma)
                return nil
            }
        } else {
            return nil
        }
    }
}
