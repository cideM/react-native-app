//
//  LearningCardDeeplink.swift
//  Interfaces
//
//  Created by CSH on 28.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct LearningCardDeeplink: Equatable {
    public let learningCard: LearningCardIdentifier
    public let anchor: LearningCardAnchorIdentifier?
    public let particle: LearningCardAnchorIdentifier?
    public let sourceAnchor: LearningCardAnchorIdentifier?
    public let question: QBankQuestionIdentifier?
    public let searchSessionID: String? // -> only used by LearningCardTracker.trackArticleFindInPageEdited

    // sourcery: fixture:
    public init(learningCard: LearningCardIdentifier, anchor: LearningCardAnchorIdentifier?, particle: LearningCardAnchorIdentifier?, sourceAnchor: LearningCardAnchorIdentifier?, question: QBankQuestionIdentifier? = nil, searchSessionID: String? = nil) {
        self.learningCard = learningCard
        self.anchor = anchor
        self.sourceAnchor = sourceAnchor
        self.question = question
        self.searchSessionID = searchSessionID
        self.particle = particle
    }

    init(learningCard: String, anchor: String?, particle: String?, sourceAnchor: String?, question: String?) {
        self.learningCard = LearningCardIdentifier(value: learningCard)
        self.anchor = anchor.map { LearningCardAnchorIdentifier(value: $0) }
        self.sourceAnchor = sourceAnchor.map { LearningCardAnchorIdentifier(value: $0) }
        self.question = question.map { QBankQuestionIdentifier(value: $0) }
        self.searchSessionID = nil
        self.particle = particle.map { LearningCardAnchorIdentifier(value: $0) }
    }

    public init?(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        self.init(urlComponents: urlComponents)
    }

    // Note: This is a new kind of URL that we are currently not supporting
    // https://next.amboss.com/de/questions/PmLF0Wfyi3/2/article/7N04cg#Z2ad72336313c69c3df64280819ca8d74
    public init?(urlComponents: URLComponents) {
        let path = urlComponents.pathComponents
        let fragmentItems = urlComponents.fragmentQueryItems
        switch path {
        // /us/article/:learningcardid#:anchor
        case ["us", "article", .xid(length: 6)],
            ["de", "article", .xid(length: 6)]:
            self.init(learningCard: path[2], anchor: fragmentItems?.first?.name, particle: nil, sourceAnchor: nil, question: nil)

        // /de/app2web/library/:learningcardid/:anchor/:questionidentifier
        case [.any, "app2web", "library", .xid(length: 6), .any, .any]:
            self.init(learningCard: path[3], anchor: path[4], particle: nil, sourceAnchor: nil, question: path[5])

        // /de/library#xid=:learningcardid&anker=:anchor
        case ["de", "library"],
            ["us", "library"],
            ["library"]:
            guard let xid = fragmentItems?["xid"] else { return nil }
            let anchorString = fragmentItems?["anker"] ?? fragmentItems?["anchor"]
            let questionString = fragmentItems?["question"] ?? fragmentItems?["questionId"]
            self.init(learningCard: xid, anchor: anchorString, particle: nil, sourceAnchor: nil, question: questionString)

        default: return nil
        }
    }

    public func withSearchSessionID(_ id: String?) -> LearningCardDeeplink {
        .init(learningCard: learningCard, anchor: anchor, particle: particle, sourceAnchor: sourceAnchor, searchSessionID: id)
    }
}
