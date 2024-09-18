//
//  FontFamily.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 23.08.23.
//

import Foundation

public enum FontFamily: TokenRepresentable, CaseIterable {
    public typealias RawValue = any TypeFace.Type

    case lato

    public var rawValue: RawValue {
        switch self {
        case .lato: return Lato.self
        }
    }
}
