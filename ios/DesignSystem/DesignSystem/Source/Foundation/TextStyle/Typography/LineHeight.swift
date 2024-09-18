//
//  LineHeight.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.08.23.
//

import Foundation

public enum LineHeight: TokenRepresentable {
    public typealias RawValue = CGFloat

    case s
    case m
    case l

    public var rawValue: RawValue {
        switch self {
        case .s: return LineHeightTokens.s
        case .m: return LineHeightTokens.m
        case .l: return LineHeightTokens.l
        }
    }
}
