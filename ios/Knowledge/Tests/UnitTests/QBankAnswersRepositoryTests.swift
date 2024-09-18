//
//  QBankAnswersRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 10.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class QBankAnswersRepositoryTests: XCTestCase {
    var storage: Storage!
    var repository: QBankAnswerRepositoryType!

    override func setUp() {
        storage = MemoryStorage()
        repository = QBankAnswerRepository(storage: storage)
    }

    func testThatImportingAnswersThatContainWrongOnesPersistsThemInTheStorage() {
        let answersToImport: [QBankAnswer] = [.fixture(questionId: .fixture(), status: .incorrect)]

        repository.importWrongAnswers(answersToImport)

        let persistedAnswers: [QBankAnswer] = storage.get(for: .qbankAnswers) ?? []
        answersToImport.forEach { XCTAssert(persistedAnswers.contains($0)) }
    }

    func testThatImportingAnswersThatContainWrongAndCorrectOnesOnlyPersistsTheWrongAnswersInTheStorage() {
        let answersToImport: [QBankAnswer] = [.fixture(questionId: .fixture(value: "spec_1"), status: .incorrect), .fixture(questionId: .fixture(), status: .correct)]

        repository.importWrongAnswers(answersToImport)

        let persistedAnswers: [QBankAnswer] = storage.get(for: .qbankAnswers) ?? []
        XCTAssertEqual(persistedAnswers.count, 1)
        XCTAssertEqual(persistedAnswers.first?.questionId, QBankQuestionIdentifier("spec_1"))
        XCTAssertEqual(persistedAnswers.first?.status, .incorrect)
    }

    func testThatImportingAnswersThatContainACorrectStatusForAPersistedWrongAnswerRemovesThatAnswerFromTheStorage() {
        let availableAnswers = [QBankAnswer(questionId: .fixture(value: "spec_1"), status: .incorrect)]
        storage.store(availableAnswers, for: .qbankAnswers)
        let answersToImport: [QBankAnswer] = [.fixture(questionId: .fixture(value: "spec_1"), status: .correct)]

        repository.importWrongAnswers(answersToImport)

        let persistedAnswers: [QBankAnswer] = storage.get(for: .qbankAnswers) ?? []
        XCTAssertEqual(persistedAnswers, [])
    }

    func testThatTheRepositoryReturnsTheCorrectWronglyAnsweredQuestionsWhenAskedForThem() {
        let availableAnswers = [QBankAnswer(questionId: .fixture(value: "spec_1"), status: .incorrect), QBankAnswer(questionId: .fixture(value: "spec_2"), status: .correct)]
        storage.store(availableAnswers, for: .qbankAnswers)

        let wronglyAnsweredQuestions = repository.wronglyAnsweredQuestions()

        XCTAssertEqual(wronglyAnsweredQuestions.count, 1)
        XCTAssertEqual(wronglyAnsweredQuestions.first, .fixture(value: "spec_1"))
    }

    func testThatTheRepositoryReturnsTheCorrectWronglyAnsweredQuestionsFromAnArrayOfQuestionIDsWhenAskedForThem() {
        let availableAnswers = [QBankAnswer(questionId: .fixture(value: "spec_1"), status: .incorrect), QBankAnswer(questionId: .fixture(value: "spec_2"), status: .correct), QBankAnswer(questionId: .fixture(value: "spec_3"), status: .incorrect)]
        storage.store(availableAnswers, for: .qbankAnswers)

        let wronglyAnsweredQuestions = repository.wronglyAnsweredQuestions(for: [.fixture(value: "spec_3")])

        XCTAssertEqual(wronglyAnsweredQuestions.count, 1)
        XCTAssertEqual(wronglyAnsweredQuestions.first, .fixture(value: "spec_3"))
    }

    func testThatCallingRemoveAllDataFromLocalStorageClearsAllStoredQuestions() {
        let availableAnswers = [QBankAnswer(questionId: .fixture(value: "spec_1"), status: .incorrect), QBankAnswer(questionId: .fixture(value: "spec_2"), status: .correct)]
        storage.store(availableAnswers, for: .qbankAnswers)

        repository.removeAllDataFromLocalStorage()

        let persistedAnswers: [QBankAnswer]? = storage.get(for: .qbankAnswers) ?? []

        XCTAssertEqual(persistedAnswers, [])
    }
}
