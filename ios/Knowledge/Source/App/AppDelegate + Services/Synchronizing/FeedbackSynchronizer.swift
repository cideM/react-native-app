//
//  FeedbackSynchronizer.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 18.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

final class FeedbackSynchronizer: Synchronizer {
    private let learningCardClient: LearningCardLibraryClient
    private let feedbackRepository: FeedbackRepositoryType
    private let trackingProvider: TrackingType
    @Inject private var monitor: Monitoring
    private var feedbacksDidChangeNotificationObserver: NSObjectProtocol?

    init(learningCardClient: LearningCardLibraryClient = resolve(), feedbackRepository: FeedbackRepositoryType = resolve(), trackingProvider: TrackingType = resolve()) {
        self.learningCardClient = learningCardClient
        self.feedbackRepository = feedbackRepository
        self.trackingProvider = trackingProvider

        feedbacksDidChangeNotificationObserver = NotificationCenter.default.observe(for: FeedbacksDidChangeNotification.self, object: feedbackRepository, queue: .main) { [weak self] change in
            guard let self = self, !change.newValue.isEmpty else { return }
            NotificationCenter.default.post(SynchronizerNeedsSynchronization(synchronizer: self), sender: self)
        }
    }

    func synchronize(_ completion: @escaping (SynchronizationResult) -> Void) {
        monitor.debug("Starting feedBackSynchronization", context: .synchronization)
        synchronizeNext(feedbacksAlreadySent: 0, completion)
    }

    func removeAllDataFromLocalStorage() {
        feedbackRepository.removeAllDataFromLocalStorage()
    }

    private func synchronizeNext(feedbacksAlreadySent: Int, _ completion: @escaping (SynchronizationResult) -> Void) {
        guard let feedback = feedbackRepository.getFirstFeedback() else {
            let message = feedbacksAlreadySent > 0 ? "Finished feedBackSynchronization with updates" : "Finished feedBackSynchronization with no updates"
            monitor.debug(message, context: .synchronization)
            return feedbacksAlreadySent > 0 ? completion(.updated) : completion(.notUpdated)
        }

        learningCardClient.submitFeedback(feedback) { [synchronizeNext, feedbackRepository, monitor] result in
            switch result {
            case .success:
                feedbackRepository.removeFeedback(feedback)
                synchronizeNext(feedbacksAlreadySent + 1, completion)
            case .failure(let error):
                monitor.error(FeedbackSynchronizerError.failedToSubmitFeedback(error), context: .synchronization)
                completion(.failed)
            }
        }
    }
}

private extension FeedbackSynchronizer {
    enum FeedbackSynchronizerError: Error {
        case failedToSubmitFeedback(Error)
    }
}
