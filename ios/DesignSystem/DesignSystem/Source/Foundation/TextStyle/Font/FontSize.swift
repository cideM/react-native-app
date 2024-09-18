//
//  FontSize.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.08.23.
//

import Foundation

public enum FontSize: TokenRepresentable {
    public typealias RawValue = CGFloat

    case textXS
    case textS
    case textM
    case headerXS
    case headerS
    case headerM
    case headerL
    case headerXL

    public var rawValue: RawValue {
        switch self {

        case .textXS: return FontSizeTokens.textXS
        case .textS:  return FontSizeTokens.textS
        case .textM: return FontSizeTokens.textM
        case .headerXS: return FontSizeTokens.headerXS
        case .headerS: return FontSizeTokens.headerS
        case .headerM: return FontSizeTokens.headerM
        case .headerL: return FontSizeTokens.headerL
        case .headerXL: return FontSizeTokens.headerXL
        }
    }
}
