//
//  NSAttributedString+TextStyle.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 29.08.23.
//

import UIKit

public extension NSAttributedString {
    static func attributedString(with text: String,
                                 style: TextStyle,
                                 decorations: [TextDecoration] = .default) -> NSMutableAttributedString {
        style.attributedString(from: text, with: decorations)
    }

    func with(_ lineBreakMode: NSLineBreakMode) -> NSAttributedString {
        // If string is empty -> no need to change lineBreakMode.
        // It will cause range exceptions if attempted.
        guard !string.isEmpty else { return self }
        let attributes = attributes(at: 0, effectiveRange: nil)
        var result = NSMutableAttributedString(attributedString: self)
        if let oldStyle = attributes[.paragraphStyle] as? NSParagraphStyle,
           let newStyle = oldStyle.mutableCopy() as? NSMutableParagraphStyle {
            newStyle.lineBreakMode = lineBreakMode
            result.addAttribute(.paragraphStyle, value: newStyle, range: NSRange(location: 0, length: string.count))
        } else {
            let newStyle = NSMutableParagraphStyle()
            newStyle.lineBreakMode = lineBreakMode
            result.addAttribute(.paragraphStyle, value: newStyle, range: NSRange(location: 0, length: string.count))
        }

        return result
    }

    func with(_ decorations: [TextDecoration]) -> NSAttributedString {
        var attributedString = NSMutableAttributedString(attributedString: self)
        decorations.forEach { $0.decorate(&attributedString) }
        return attributedString
    }
}

public extension Dictionary where Key == NSAttributedString.Key, Value == Any {
    static func attributes(style: TextStyle,
                           with decorations: [TextDecoration] = .default) -> [NSAttributedString.Key: Any] {
        style.attributes(with: decorations)
    }

    func with(_ lineBreakMode: NSLineBreakMode) -> [Key: Value] {
        var newAttributes = self
        if let oldStyle = self[.paragraphStyle] as? NSParagraphStyle,
           let newStyle = oldStyle.mutableCopy() as? NSMutableParagraphStyle {
            newStyle.lineBreakMode = lineBreakMode
            newAttributes[.paragraphStyle] = newStyle
        } else {
            let newStyle = NSMutableParagraphStyle()
            newStyle.lineBreakMode = lineBreakMode
            newAttributes[.paragraphStyle] = newStyle
        }
        return newAttributes
    }
}
