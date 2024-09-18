//
//  QBankAnswerRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 10.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

/// @mockable
protocol QBankAnswerRepositoryType: AnyObject {
    func importWrongAnswers(_ newAnswers: [QBankAnswer])
    func wronglyAnsweredQuestions() -> [QBankQuestionIdentifier]
    func wronglyAnsweredQuestions(for questionIDs: [QBankQuestionIdentifier]) -> [QBankQuestionIdentifier]

    func removeAllDataFromLocalStorage()
}

final class QBankAnswerRepository: QBankAnswerRepositoryType {
    private let storage: Storage
    private var answers: [QBankAnswer] {
        get {
            storage.get(for: .qbankAnswers) ?? []
        }
        set {
            storage.store(newValue, for: .qbankAnswers)
        }
    }

    init(storage: Storage) {
        self.storage = storage
    }

    func importWrongAnswers(_ newAnswers: [QBankAnswer]) {
        for answer in newAnswers where answers.contains(answer) && answer.status == .correct {
            answers.removeAll { $0 == answer }
        }
        answers += newAnswers.filter { $0.status == .incorrect }
    }

    func wronglyAnsweredQuestions() -> [QBankQuestionIdentifier] {
        answers
            .filter { $0.status == .incorrect }
            .map { $0.questionId }
    }

    func wronglyAnsweredQuestions(for questionIDs: [QBankQuestionIdentifier]) -> [QBankQuestionIdentifier] {
        answers
            .filter { questionIDs.contains($0.questionId) && $0.status == .incorrect }
            .map { $0.questionId }
    }

    func removeAllDataFromLocalStorage() {
        answers = []
    }
}
