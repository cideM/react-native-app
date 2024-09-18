//
//  TextDecoration.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 29.08.23.
//

import UIKit

public enum TextDecoration {
    case color(UIColor)
    case italic
    case underline(UIColor)
    case alignment(NSTextAlignment)

    func decorate(_ attributes: inout [NSAttributedString.Key: Any]) {
        switch self {
        case .color(let value):
            attributes[.foregroundColor] = value
        case .italic:
            guard let oldFont = attributes[.font] as? UIFont else { return }
            attributes[.font] = oldFont.italic()
        case .underline(let color):
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            attributes[.underlineColor] = color
        case .alignment(let alignment):
            if let currentStyle = attributes[.paragraphStyle] as? NSParagraphStyle,
               let paragraphStyle = currentStyle.mutableCopy() as? NSMutableParagraphStyle {

                paragraphStyle.alignment = alignment
                attributes[.paragraphStyle] = paragraphStyle
            } else {
                let paragraphStyle = NSMutableParagraphStyle(alignment: alignment)
                attributes[.paragraphStyle] = paragraphStyle
            }
        }
    }
    func decorate(_ attrString: inout NSMutableAttributedString) {
        // If string is empty -> no need to decorate.
        // It will cause range exceptions if attempted.
        guard !attrString.string.isEmpty else { return }

        let fullRange = NSRange(location: 0, length: attrString.length)
        switch self {
        case .color(let value):
            attrString.addAttributes([.foregroundColor: value],
                                 range: fullRange)
        case .italic:
            let attributes = attrString.attributes(at: 0, effectiveRange: nil)
            guard let oldFont = attributes[.font] as? UIFont else { return }

            attrString.addAttributes([.font: oldFont.italic()],
                                 range: fullRange)
        case .underline(let color):
            attrString.addAttributes([.underlineColor: color, .underlineStyle: NSUnderlineStyle.single.rawValue],
                                 range: fullRange)
        case .alignment(let alignment):
            let attributes = attrString.attributes(at: 0, effectiveRange: nil)
            if let currentStyle = attributes[.paragraphStyle] as? NSParagraphStyle,
               let paragraphStyle = currentStyle.mutableCopy() as? NSMutableParagraphStyle {

                paragraphStyle.alignment = alignment
                attrString.addAttributes([.paragraphStyle: paragraphStyle], range: fullRange)
            } else {
                let paragraphStyle = NSMutableParagraphStyle(alignment: alignment)
                attrString.addAttributes([.paragraphStyle: paragraphStyle], range: fullRange)
            }
        }
    }
}

public extension Array where Element == TextDecoration {

    static let `default`: [TextDecoration] = [.color(.textPrimary)]

}
