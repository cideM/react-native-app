//
//  NSMutableParagraphStyle+Convenience.swift
//  AmbossDesignSystem
//
//  Created by Roberto Seidenberg on 12.04.23.
//

import UIKit

public extension NSMutableParagraphStyle {

    convenience init(
        lineHeight height: CGFloat? = nil,
        alignment: NSTextAlignment = .left,
        linebreakMode: NSLineBreakMode = .byWordWrapping,
        lineHeightMultiple: CGFloat? = nil
    ) {
        self.init()

        if let height = height {
            self.minimumLineHeight = height
            self.maximumLineHeight = height
        }

        if let lineHeightMultiple = lineHeightMultiple {
            self.lineHeightMultiple = lineHeightMultiple
        }

        self.alignment = alignment
        self.lineBreakMode = linebreakMode
    }
}
