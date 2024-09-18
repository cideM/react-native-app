//
//  PharmaRichTextAttribute.swift
//  RichTextRenderer
//
//  Created by Mohamed Abdul Hameed on 22.01.21.
//

import Foundation

enum PharmaRichTextAttribute {
    static let phrasionary: (key: NSAttributedString.Key, keyPath: KeyPath<Phrasionary, Phrasionary.Data>) = (NSAttributedString.Key(rawValue: "amboss_rich_text_phrasionary"), \.data)
    static let ambossLink: (key: NSAttributedString.Key, keyPath: KeyPath<AmbossLink, AmbossLink.Data>) = (NSAttributedString.Key(rawValue: "amboss_rich_text_link"), \.data)
}
