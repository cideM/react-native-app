//
//  Typography.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 02.06.23.
//

import UIKit

public struct Typography {
    let fontFamily: FontFamily
    let fontSize: FontSize
    let fontWeight: FontWeight
    let lineHeight: LineHeight
    let letterSpacing: LetterSpacing
    let paragraphSpacing: ParagraphSpacing

    internal init(fontFamily: FontFamily,
                  fontSize: FontSize,
                  fontWeight: FontWeight,
                  lineHeight: LineHeight,
                  letterSpacing: LetterSpacing = .none,
                  paragraphSpacing: ParagraphSpacing = .none) {

        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.letterSpacing = letterSpacing
        self.lineHeight = lineHeight
        self.paragraphSpacing = paragraphSpacing
    }

    public func font() -> UIFont {
        .font(family: fontFamily,
                     weight: fontWeight,
                     size: fontSize) ?? UIFont.systemFont(ofSize: fontSize.rawValue,
                                                          weight: fontWeight.rawValue)
    }

    // MARK: - Attributed Strings

    public func attributes() -> [NSAttributedString.Key: Any] {
        let font = font()
        var result: [NSAttributedString.Key: Any] = [
            .font: font,
            .kern: letterSpacing.rawValue
        ]

        if let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle {
            paragraphStyle.alignment = .natural
            paragraphStyle.paragraphSpacing = paragraphSpacing.rawValue
            paragraphStyle.minimumLineHeight = lineHeight.rawValue * font.lineHeight
            paragraphStyle.maximumLineHeight = lineHeight.rawValue * font.lineHeight
            // Calculate baselineOffset to center text vertically within the line
            let lineHeightDiffernece = (lineHeight.rawValue * font.lineHeight) - font.lineHeight
            let baselineOffset = lineHeightDiffernece / 2.0 // This value holds for Lato font family

            result[.paragraphStyle] = paragraphStyle
            result[.baselineOffset] = baselineOffset
        }
        return result
    }

    public func attributedString(from string: String) -> NSMutableAttributedString {
        NSMutableAttributedString(string: string, attributes: attributes())
    }
}
