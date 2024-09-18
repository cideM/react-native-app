//
//  QBankAnswerSynchronizer.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 10.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

final class QBankAnswerSynchronizer: Synchronizer {
    private let answerRepository: QBankAnswerRepositoryType
    private let qbankClient: QbankClient
    private let storage: Storage
    private let trackingProvider: TrackingType
    @Inject private var monitor: Monitoring

    private var answersEndCursor: PaginationCursor? {
        get {
            storage.get(for: .qbankAnswersEndCursor)
        }
        set {
            storage.store(newValue, for: .qbankAnswersEndCursor)
        }
    }

    init(answerRepository: QBankAnswerRepositoryType = resolve(), qbankClient: QbankClient = resolve(), storage: Storage = resolve(tag: .default), trackingProvider: TrackingType = resolve()) {
        self.answerRepository = answerRepository
        self.qbankClient = qbankClient
        self.storage = storage
        self.trackingProvider = trackingProvider
    }

    func synchronize(_ completion: @escaping (SynchronizationResult) -> Void) {
        monitor.debug("Starting answers synchronisation.", context: .synchronization)
        downloadAnswers(didAlreadySynchronizeData: false, completion)
    }

    func removeAllDataFromLocalStorage() {
        answersEndCursor = nil
        answerRepository.removeAllDataFromLocalStorage()
    }

    private func downloadAnswers(didAlreadySynchronizeData: Bool, _ completion: @escaping (SynchronizationResult) -> Void) {
        qbankClient.getMostRecentAnswerStatuses(after: answersEndCursor) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(nil):
                if didAlreadySynchronizeData {
                    completion(.updated)
                } else {
                    completion(.notUpdated)
                }
            case .success(let page):
                guard let page = page else { return }
                self.answersEndCursor = page.nextPage
                self.answerRepository.importWrongAnswers(page.elements)
                if page.hasNextPage {
                    self.downloadAnswers(didAlreadySynchronizeData: true, completion)
                } else {
                    completion(.updated)
                }
            case .failure(let error):
                self.monitor.error(QBankAnswerSynchronizerError.downloadFailed(error), context: .synchronization)
                completion(.failed)
            }
        }
    }
}

extension QBankAnswerSynchronizer {
    enum QBankAnswerSynchronizerError: Error {
        case downloadFailed(Error)
    }
}
