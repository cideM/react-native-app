//
//  Page.swift
//  Networking
//
//  Created by Silvio Bulla on 25.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
import KnowledgeGraphQLEntities

enum PageParsingError: Error {
    case endCursorNotFound
}

enum TaggingParsingError: Error {
    case invalidTag(String)
    case invalidDateFormat(String)
}

enum ExtensionParsingError: Error {
    case invalidDateFormat(String)
}

public typealias PaginationCursor = String

public struct Page<T> {
    public let elements: [T]
    public let nextPage: PaginationCursor
    public let hasNextPage: Bool

    public init(elements: [T], nextPage: PaginationCursor, hasNextPage: Bool) {
        self.elements = elements
        self.nextPage = nextPage
        self.hasNextPage = hasNextPage
    }
}

extension Page where T == Tagging {
    init?(articleInteraction: ArticleInteractionsQuery.Data.CurrentUser.ArticleInteractions, dateFormatter: ISO8601DateFormatter) throws {
        guard !articleInteraction.edges.isEmpty else { return nil }
        guard let endCursor = articleInteraction.pageInfo.endCursor else { throw PageParsingError.endCursorNotFound }
        nextPage = endCursor
        hasNextPage = articleInteraction.pageInfo.hasNextPage
        elements = try articleInteraction.edges.compactMap { edge -> Tagging? in
            guard let value = edge.node.type.value, let tag = Tag(type: value) else { throw TaggingParsingError.invalidTag(edge.node.type.rawValue) }
            guard let updatedAt = dateFormatter.date(from: edge.node.updatedAt) else { throw TaggingParsingError.invalidDateFormat(edge.node.updatedAt) }

            return Tagging(type: tag, active: edge.node.active, updatedAt: updatedAt, learningCard: LearningCardIdentifier(value: edge.node.articleEid))
        }
    }
}

extension Page where T == Extension {
    init?(ext: CurrentUserExtensionsQuery.Data.CurrentUser.ParticleExtensions, dateFormatter: ISO8601DateFormatter) throws {
        guard !ext.edges.isEmpty else { return nil }
        guard let endCursor = ext.pageInfo.endCursor else { throw PageParsingError.endCursorNotFound }
        nextPage = endCursor
        hasNextPage = ext.pageInfo.hasNextPage
        elements = try ext.edges.compactMap { edge -> Extension? in
            let text = edge.node.text ?? ""
            guard let updatedAt = dateFormatter.date(from: edge.node.updatedAt) else { throw ExtensionParsingError.invalidDateFormat(edge.node.updatedAt) }

            return Extension(learningCard: LearningCardIdentifier(value: edge.node.particle.article.eid), section: LearningCardSectionIdentifier(value: edge.node.particleEid), updatedAt: updatedAt, previousUpdatedAt: updatedAt, note: text)
        }
    }
}

extension Page where T == Extension {
    init?(ext: ExtensionsForUserQuery.Data.UserParticleExtensions, dateFormatter: ISO8601DateFormatter) throws {
        guard !ext.edges.isEmpty else { return nil }
        guard let endCursor = ext.pageInfo.endCursor else { throw PageParsingError.endCursorNotFound }
        nextPage = endCursor
        hasNextPage = ext.pageInfo.hasNextPage
        elements = try ext.edges.compactMap { edge -> Extension? in
            let text = edge.node.text ?? ""
            guard let updatedAt = dateFormatter.date(from: edge.node.updatedAt) else { throw ExtensionParsingError.invalidDateFormat(edge.node.updatedAt) }

            return Extension(learningCard: LearningCardIdentifier(value: edge.node.particle.article.eid), section: LearningCardSectionIdentifier(value: edge.node.particleEid), updatedAt: updatedAt, previousUpdatedAt: updatedAt, note: text)
        }
    }
}

extension Page where T == User {
    init?(user: UsersWhoShareExtensionsWithCurrentUserQuery.Data.CurrentUser.UsersWhoShareNotesWithMe, dateFormatter: ISO8601DateFormatter) throws {
        guard !user.edges.isEmpty else { return nil }
        guard let endCursor = user.pageInfo.endCursor else { throw PageParsingError.endCursorNotFound }
        nextPage = endCursor
        hasNextPage = user.pageInfo.hasNextPage
        elements = user.edges.compactMap { user -> User? in
            User(userIdentifier: UserIdentifier(value: user.node.eid), firstName: user.node.firstName, lastName: user.node.lastName, email: user.node.email)
        }
    }
}

extension Page where T == QBankAnswer {
    init?(answerStatusConnection: MostRecentAnswerStatusesQuery.Data.CurrentUser.MostRecentAnswerStatuses.AsAnswerStatusConnection) throws {
        guard !answerStatusConnection.edges.isEmpty else { return nil }
        guard let endCursor = answerStatusConnection.pageInfo.endCursor else { throw PageParsingError.endCursorNotFound }
        nextPage = endCursor
        hasNextPage = answerStatusConnection.pageInfo.hasNextPage
        elements = answerStatusConnection.edges.compactMap { answer -> QBankAnswer? in
            guard let questionId = QBankQuestionIdentifier(answer.node.questionId), let status = QBankAnswer.Status(rawValue: answer.node.status.rawValue) else { return nil }
            return QBankAnswer(questionId: questionId, status: status)
        }
    }
}

extension Page where T == ArticleSearchItem {
    init?(articleContentTree: SearchArticleResultsQuery.Data.SearchArticleContentTree) throws {
        guard !articleContentTree.edges.isEmpty else { return nil }
        guard let endCursor = articleContentTree.pageInfo.endCursor else { throw PageParsingError.endCursorNotFound }
        nextPage = endCursor
        hasNextPage = articleContentTree.pageInfo.hasNextPage
        elements = articleContentTree.edges.compactMap { ArticleSearchItem(from: $0?.node) }
    }
}

extension Page where T == PharmaSearchItem {
    init?(searchPharmaResult: SearchPharmaResultsQuery.Data.SearchPharmaAgentResults) throws {
        guard !searchPharmaResult.edges.isEmpty else { return nil }
        guard let endCursor = searchPharmaResult.pageInfo.endCursor else { throw PageParsingError.endCursorNotFound }
        nextPage = endCursor
        hasNextPage = searchPharmaResult.pageInfo.hasNextPage
        elements = searchPharmaResult.edges.compactMap { PharmaSearchItem(from: $0?.node) }
    }
}

extension Page where T == MonographSearchItem {
    init?(searchMonographResult: SearchMonographResultsQuery.Data.SearchAmbossSubstanceResults) throws {
        guard !searchMonographResult.edges.isEmpty else { return nil }
        guard let endCursor = searchMonographResult.pageInfo.endCursor else { throw PageParsingError.endCursorNotFound }
        nextPage = endCursor
        hasNextPage = searchMonographResult.pageInfo.hasNextPage
        elements = searchMonographResult.edges.compactMap { MonographSearchItem(from: $0?.node) }
    }
}

extension Page where T == GuidelineSearchItem {
    init?(searchGuidelineResult: SearchGuidelineResultsQuery.Data.SearchGuidelineResults) throws {
        guard !searchGuidelineResult.edges.isEmpty else { return nil }
        guard let endCursor = searchGuidelineResult.pageInfo.endCursor else { throw PageParsingError.endCursorNotFound }
        nextPage = endCursor
        hasNextPage = searchGuidelineResult.pageInfo.hasNextPage
        elements = searchGuidelineResult.edges.compactMap { GuidelineSearchItem(from: $0?.node) }
    }
}

extension Page where T == MediaSearchItem {
    init?(searchMediaResult: SearchMediaResultsQuery.Data.SearchMediaResults) throws {
        guard !searchMediaResult.edges.isEmpty else { return nil }
        guard let endCursor = searchMediaResult.pageInfo.endCursor else { throw PageParsingError.endCursorNotFound }
        nextPage = endCursor
        hasNextPage = searchMediaResult.pageInfo.hasNextPage
        elements = searchMediaResult.edges.compactMap { MediaSearchItem(from: $0?.node) }
    }
}
