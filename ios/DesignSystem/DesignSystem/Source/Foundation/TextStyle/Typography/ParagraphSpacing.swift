//
//  ParagraphSpacing.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.08.23.
//

import Foundation

public enum ParagraphSpacing: TokenRepresentable {

    public typealias RawValue = CGFloat

    case none
    case m
    case l

    public var rawValue: CGFloat {
        switch self {
        case .none: return ParagraphSpacingTokens.none
        case .m: return ParagraphSpacingTokens.m
        case .l: return ParagraphSpacingTokens.l
        }
    }
}
