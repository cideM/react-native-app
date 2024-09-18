//
//  RichTextTableViewCellDelegate.swift
//  RichTextRenderer
//
//  Created by Mohamed Abdul Hameed on 22.01.21.
//

import Foundation

public protocol RichTextCellDelegate: AnyObject {
    /// Pharma Rich Text content can have phrasionaries and links.
    /// Every phrasionary item has an amboss link inside it.
    /// Not every amboss link is associated with a phrasionary item.
    func didTapPharmaRichTextLink(phrasionary: Phrasionary.Data?, ambossLink: AmbossLink.Data?)
}
