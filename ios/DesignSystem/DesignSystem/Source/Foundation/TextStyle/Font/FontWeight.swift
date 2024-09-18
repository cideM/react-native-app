//
//  FontWeight.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.08.23.
//

import UIKit

public enum FontWeight: TokenRepresentable {
    public typealias RawValue = UIFont.Weight

    case regular
    case bold
    case black

    public var rawValue: RawValue {
        switch self {
        case .regular: return .fromCSSValue(FontWeightTokens.regular)
        case .bold: return .fromCSSValue(FontWeightTokens.bold)
        case .black: return .fromCSSValue(FontWeightTokens.black)
        }
    }

    func upper() -> FontWeight {
        switch self {
        case .regular: return .bold
        case .bold, .black: return .black
        }
    }
    func lower() -> FontWeight {
        switch self {
        case .regular, .bold: return .regular
        case .black: return .bold
        }
    }
}
