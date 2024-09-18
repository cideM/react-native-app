//
//  LearningCardHtmlAPIError+PresentableError.swift
//  Knowledge
//
//  Created by CSH on 14.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import Localization

extension LearningCardHtmlAPIError: PresentableMessageType {

    public var debugDescription: String {
        "\(self)"
    }

    public var title: String {
        switch self {
        case .learningCardNotFound: return L10n.Error.Generic.title
        }
    }

    public var body: String {
        switch self {
        case .learningCardNotFound: return L10n.LearningCard.Error.LearningCardNotFound.message
        }
    }

    public var logLevel: MonitorLevel {
        switch self {
        case .learningCardNotFound: return .warning
        }
    }
}
