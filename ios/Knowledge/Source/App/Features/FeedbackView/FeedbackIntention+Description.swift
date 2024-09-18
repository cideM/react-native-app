//
//  FeedbackIntention+Description.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 17.02.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
import Localization

extension FeedbackIntention: CustomStringConvertible {
    public var description: String {
        switch self {
        case .languageIssue:
            return L10n.Feedback.IntentionsMenu.Intentions.languageIssue
        case .incorrectContent:
            return L10n.Feedback.IntentionsMenu.Intentions.incorrectContent
        case .missingContent:
            return L10n.Feedback.IntentionsMenu.Intentions.missingContent
        case .technicalIssue:
            return L10n.Feedback.IntentionsMenu.Intentions.technicalIssue
        case .media:
            return L10n.Feedback.IntentionsMenu.Intentions.mediaFeedback
        case .productFeedback:
            return L10n.Feedback.IntentionsMenu.Intentions.productFeedback
        case .praise:
            return L10n.Feedback.IntentionsMenu.Intentions.praise
        }
    }
}
