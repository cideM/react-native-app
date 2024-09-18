//
//  WebViewBridge.Call.swift
//  Knowledge
//
//  Created by CSH on 28.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

extension WebViewBridge {
    enum Call {
        case scrollToAnchor(LearningCardAnchorIdentifier, QBankQuestionIdentifier?)
        case openAllSections
        case closeAllSections
        case changeHighlightingMode(Bool)
        case changeHighYieldMode(Bool)
        case changePhysikumFokusMode(Bool)
        case changeLearningRadarMode(Bool)
        case setPhysicianModeIsOn(Bool)
        case activateStudyObjective(String)
        case setExtensions([Extension])
        case setFontSize(Float)
        case scrollToQueryResult(InArticleResultIndentifier)
        case disposeQuery(InArticleSearchResponseIdentifier)
        case setSharedExtensions([SharedExtension])
        case setWrongAnsweredQuestions([QBankQuestionIdentifier])
        case hideTrademarks
        case revealTrademarks
        case revealDosages

        var jsCall: String {
            switch self {
            case .scrollToAnchor(let anchor, let question):
                if let question = question {
                    return "Amboss.LearningCard.scrollToElement('\(anchor.value)', '\(question.value)');"
                } else {
                    return "Amboss.LearningCard.scrollToElement('\(anchor.value)');"
                }
            case .openAllSections: return "Amboss.LearningCard.openAllSections();"
            case .closeAllSections: return "Amboss.LearningCard.closeAllSections();"
            case .changeHighlightingMode(let isOn): return "Amboss.LearningCard.highlight(\(isOn));"
            case .changeHighYieldMode(let isOn): return "Amboss.LearningCard.setCondensedModeActive(\(isOn));"
            case .changePhysikumFokusMode(let isOn): return "Amboss.LearningCard.setPreclinicFocusModeActive(\(isOn));"
            case .changeLearningRadarMode(let isOn): return "Amboss.LearningCard.toggleLearningRadar(\(isOn));"
            case .setPhysicianModeIsOn(let isOn): return "Amboss.LearningCard.setAdditionalKnowledgeVisible(\(isOn));"
            case .activateStudyObjective(let studyObjective): return "Amboss.LearningCard.activateStudyObjectives(['\(studyObjective)']);"
            case .setExtensions(let extensions):
                let extensionsDictionary = extensions.reduce(into: [String: String]()) {
                    $0[$1.section.description] = $1.note
                }
                if let extensionsJSON = try? JSONSerialization.data(withJSONObject: extensionsDictionary, options: []), let extensionsJSONString = String(data: extensionsJSON, encoding: .utf8) {
                    return "Amboss.LearningCard.setExtensionContent(\(extensionsJSONString));"
                } else {
                    return "Amboss.LearningCard.setExtensionContent({});"
                }
            case .setFontSize(let size): return "Amboss.LearningCard.setFontSize('\(size)');"
            case .scrollToQueryResult(let queryResultId): return "Amboss.LearningCard.scrollToQueryResult('\(queryResultId.id)');"
            case .disposeQuery(let responseId): return "Amboss.LearningCard.disposeQuery('\(responseId.id)');"
            case .setSharedExtensions(let sharedExtensions):
                let sharedExtensionsDictionary = sharedExtensions.reduce(into: [[String: Any]]()) {
                    $0.append([
                        "section": $1.ext.section.description,
                        "content": $1.ext.note,
                        "modified_at": Date().timeIntervalSinceReferenceDate,
                        "author": [
                            "id": $1.user.identifier.value,
                            "first_name": $1.user.firstName,
                            "last_name": $1.user.lastName
                        ]
                    ])
                }
                if let sharedExtensionsJSON = try? JSONSerialization.data(withJSONObject: sharedExtensionsDictionary, options: []), let sharedExtensionsJSONString = String(data: sharedExtensionsJSON, encoding: .utf8) {
                    return "Amboss.LearningCard.setSharedExtensionContent(\(sharedExtensionsJSONString));"
                } else {
                    return "Amboss.LearningCard.setSharedExtensionContent({});"
                }
            case .setWrongAnsweredQuestions(let questionIDs):
                guard let questionIDsData = try? JSONSerialization.data(withJSONObject: questionIDs.map { $0.value }, options: []), let questionIDs = String(data: questionIDsData, encoding: String.Encoding.utf8) else { return "Amboss.LearningCard.setQuestionsWrong([])" }
                return "Amboss.LearningCard.setQuestionsWrong(\(questionIDs))"
            case .hideTrademarks:
                return "Amboss.LearningCard.hideTrademarks()"
            case .revealTrademarks:
                return "Amboss.LearningCard.revealTrademarks()"
            case .revealDosages:
                return "Amboss.LearningCard.revealDosages()"
            }
        }
    }
}
