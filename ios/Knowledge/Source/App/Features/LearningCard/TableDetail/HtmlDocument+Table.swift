//
//  HtmlDocument+Table.swift
//  Knowledge DE
//
//  Created by CSH on 03.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

extension HtmlDocument {
    static func tableDocument(_ table: String) -> HtmlDocument {
        let wrappedBody = "<article class=\"js-learningcard learningcard\"><div class=\"section-content js-section-content\"><div class=\"table-wrapper\"><table class=\"api\">"
            + table
            + "</table></div></div></article>"
        var document = HtmlDocument.libraryDocument(body: wrappedBody)
        document.setBodyTags([wrappedBody])
        return document
    }
}
