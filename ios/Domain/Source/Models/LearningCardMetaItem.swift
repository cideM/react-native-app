//
//  LearningCardMetaItem.swift
//  Interfaces
//
//  Created by Silvio Bulla on 07.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct LearningCardMetaItem {
    public let title: String
    public let urlPath: String
    public let preclinicFocusAvailable: Bool
    public let alwaysFree: Bool
    public let minimapNodes: [MinimapNodeMeta]
    public let learningCardIdentifier: LearningCardIdentifier
    public let galleries: [Gallery]
    private let wrappedQuestions: [QBankQuestionIdentifierWrapper]
    public var questions: [QBankQuestionIdentifier] {
        wrappedQuestions.map { $0.id }
    }

    // sourcery: fixture:
    init(title: String, urlPath: String, preclinicFocusAvailable: Bool, alwaysFree: Bool, minimapNodes: [MinimapNodeMeta], learningCardIdentifier: LearningCardIdentifier, galleries: [Gallery], questions: [QBankQuestionIdentifier]) {
        self.title = title
        self.urlPath = urlPath
        self.preclinicFocusAvailable = preclinicFocusAvailable
        self.alwaysFree = alwaysFree
        self.minimapNodes = minimapNodes
        self.learningCardIdentifier = learningCardIdentifier
        self.galleries = galleries
        self.wrappedQuestions = questions.map { QBankQuestionIdentifierWrapper(id: $0) }
    }
}

extension LearningCardMetaItem: Codable {
    enum CodingKeys: String, CodingKey {
        case title
        case urlPath = "url_path"
        case preclinicFocusAvailable = "preclinic_focus_available"
        case alwaysFree = "always_free"
        case minimapNodes = "minimap_nodes"
        case learningCardIdentifier = "xid"
        case galleries
        case wrappedQuestions = "questions"
    }

    private struct QBankQuestionIdentifierWrapper: Codable {
        let id: QBankQuestionIdentifier
    }
}

public extension LearningCardMetaItem {
    func miniMapNode(for anchor: LearningCardSectionIdentifier) -> MinimapNodeMeta? {
        minimapNodes.first { node in
            node.anchor.value == anchor.value || node.childNodes.first { $0.anchor.value == anchor.value }?.anchor.value == anchor.value
        }
    }
}
