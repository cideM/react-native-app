// RichTextRenderer

import Foundation

// Please note!
// There is a WORKAROUND for displaying this properly happening in:
// UnorderedListRenderer.swift

enum UnorderedListBullet: String, CaseIterable {
    case fullCircle = "●"
    case emptyCircle = "◦"
    case fullSquare = "▪︎"
}
