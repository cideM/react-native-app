//
//  TextStyle.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.08.23.
//

import UIKit

public enum TextStyle: String, CaseIterable {
    case h1
    case h2
    case h3
    case h4
    case h5
    case h6
    case button
    case paragraph
    case paragraphBold
    case paragraphSmall
    case paragraphSmallBold
    case paragraphExtraSmall
    case paragraphExtraSmallBold
    case h5Bold

    public var typography: Typography {
        switch self {
        case .h1: return Typography.h1
        case .h2: return Typography.h2
        case .h3: return Typography.h3
        case .h4: return Typography.h4
        case .h5: return Typography.h5
        case .h6: return Typography.h6
        case .button: return Typography.button
        case .paragraph: return Typography.paragraph
        case .paragraphBold: return Typography.paragraphBold
        case .paragraphSmall: return Typography.paragraphSmall
        case .paragraphSmallBold: return Typography.paragraphSmallBold
        case .paragraphExtraSmall: return Typography.paragraphExtraSmall
        case .paragraphExtraSmallBold: return Typography.paragraphExtraSmallBold
        case .h5Bold: return Typography.h5Bold
        }
    }

    func attributes(with decorations: [TextDecoration] = .default) -> [NSAttributedString.Key: Any] {
        var attributes = self.typography.attributes()
        decorations.forEach { $0.decorate(&attributes) }
        return attributes
    }

    func attributedString(from string: String,
                          with decorations: [TextDecoration] = .default) -> NSMutableAttributedString {
        var attributedString = self.typography.attributedString(from: string)
        decorations.forEach { $0.decorate(&attributedString) }
        return attributedString
    }
}
