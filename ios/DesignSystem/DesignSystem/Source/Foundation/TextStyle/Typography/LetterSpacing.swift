//
//  LetterSpacing.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.08.23.
//

import Foundation

public enum LetterSpacing: TokenRepresentable {

    public typealias RawValue = CGFloat

    case none
    case s
    case m
    case l

    public var rawValue: CGFloat {
        switch self {
        case .none: return LetterSpacingTokens.none
        case .s: return LetterSpacingTokens.s
        case .m: return LetterSpacingTokens.m
        case .l: return LetterSpacingTokens.l
        }
    }
}
