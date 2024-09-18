//
//  Lato.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 02.06.23.
//

import Foundation

public enum Lato: TokenRepresentable, TypeFace, CaseIterable {

    public static var familyName: String = "Lato"
    public static var variations: [String] {
        Self.allCases.map { $0.rawValue }
    }

    case black
    case bold
    case italic
    case medium
    case regular

    public var rawValue: RawValue {
        switch self {
        case .black: return "Lato-Black"
        case .bold: return "Lato-Bold"
        case .italic: return "Lato-Italic"
        case .medium: return "Lato-Medium"
        case .regular: return "Lato-Regular"
        }
    }
}
