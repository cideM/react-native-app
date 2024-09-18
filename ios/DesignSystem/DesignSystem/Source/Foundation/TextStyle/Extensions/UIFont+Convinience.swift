//
//  UIFont+Convinience.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.08.23.
//

import UIKit

extension UIFont {
    public static func font(family: FontFamily, weight: FontWeight, size: FontSize) -> UIFont? {
        UIFont(name: family.rawValue.familyName, size: size.rawValue)?.withWeight(weight.rawValue)
    }

    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor = UIFontDescriptor(fontAttributes: attributes)

        return UIFont(descriptor: descriptor, size: pointSize)

    }

    // Not sure if this is the right place?
    func italic() -> UIFont {
        if let italicDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic) {
            return UIFont(descriptor: italicDescriptor, size: pointSize)
        }
        return self
    }
}
