//
//  WebViewBridge+Extension.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 24.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension WebViewBridge {
    struct Query<T: Codable> {
        let jsQuery: String
        let expectedResultType: T.Type
    }

    enum QueryFactory {
        static func learnigCardModes() -> Query<[String]> { Query(jsQuery: "Amboss.LearningCard.modes();", expectedResultType: [String].self) }
        static func query(_ query: String) -> Query<InArticleSearchResponse?> { Query(jsQuery: "Amboss.LearningCard.query('\(query)');", expectedResultType: InArticleSearchResponse?.self) }
    }
}
