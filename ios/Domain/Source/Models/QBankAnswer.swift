//
//  QBankAnswer.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 09.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

public typealias QBankQuestionIdentifier = Identifier<Void, String>

public struct QBankAnswer: Codable, Equatable {
    // sourcery: fixture:
    public enum Status: String, Codable {
        case correct
        case incorrect
    }
    public let questionId: QBankQuestionIdentifier
    public let status: Status

    // sourcery: fixture:
    public init(questionId: QBankQuestionIdentifier, status: Status) {
        self.questionId = questionId
        self.status = status
    }

    public static func == (lhs: QBankAnswer, rhs: QBankAnswer) -> Bool {
        lhs.questionId == rhs.questionId
    }
}
