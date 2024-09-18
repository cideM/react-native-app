//
//  Color+TextStlye.swift
//  Common
//
//  Created by Roberto Seidenberg on 30.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation

extension Color {

    func attributes(
        font: FontAndSize,
        style: NSMutableParagraphStyle? = nil,
        kern: CGFloat? = nil,
        underline: NSUnderlineStyle? = nil,
        baselineOffset: Int? = nil) -> [NSAttributedString.Key: Any] {

        var attributes = [NSAttributedString.Key: Any]()

        attributes[.font] = font.font
        attributes[.foregroundColor] = self.value
        attributes[.paragraphStyle] = style
        attributes[.kern] = kern

        if let underlineStyle = underline {
            attributes[.underlineStyle] = underlineStyle.rawValue
        }

        if let offset = baselineOffset {
            attributes[.baselineOffset] = offset
        }

        return attributes
    }

    enum FontAndSize {
        case regular(Int)
        case bold(Int)
        case italic(Int)
        case black(Int)
        case medium(Int)
        case heavy(Int)

        var font: UIFont {
            switch self {
            case .regular(let size): return Font.regular.font(withSize: CGFloat(size))
            case .bold(let size): return Font.bold.font(withSize: CGFloat(size))
            case .italic(let size): return Font.italic.font(withSize: CGFloat(size))
            case .black(let size): return Font.black.font(withSize: CGFloat(size))
            case .medium(let size): return Font.medium.font(withSize: CGFloat(size))
            case .heavy(let size): return Font.heavy.font(withSize: CGFloat(size))
            }
        }
    }
}
