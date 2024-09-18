//
//  ElevationLevel.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 06.09.23.
//

import Foundation

public enum ElevationLevel: TokenRepresentable {

    public typealias RawValue = Elevation

    case none
    case one
    case two
    case three
    case four

    public var rawValue: RawValue {
        switch self {
        case .none:
            return Elevation(borderWidth: 0,
                             borderColor: .clear,
                             shadows: [])
        case .one:
            return Elevation(borderWidth: 1,
                             borderColor: .elevationBorder,
                             shadows: Self.levelOneShadows)
        case .two:
            return Elevation(borderWidth: 1,
                             borderColor: .elevationBorder,
                             shadows: Self.levelTwoShadows)
        case .three:
            return Elevation(borderWidth: 1,
                             borderColor: .elevationBorder,
                             shadows: Self.levelThreeShadows)
        case .four:
            return Elevation(borderWidth: 1,
                             borderColor: .elevationBorder,
                             shadows: Self.levelFourShadows)
        }
    }

    private static let levelOneShadows: [Shadow] = [
        Shadow(shadowRadius: 0.6,
               shadowOffset: CGSize(width: 0, height: 0.3),
               shadowColor: .init(white: 0, alpha: 0.003)),
        Shadow(shadowRadius: 5,
               shadowOffset: CGSize(width: 0, height: 2),
               shadowColor: .init(white: 0, alpha: 0.07))
    ]
    private static let levelTwoShadows: [Shadow] = [
        Shadow(shadowRadius: 1,
               shadowOffset: CGSize(width: 0, height: 0.3),
               shadowColor: .init(white: 0, alpha: 0.1)),
        Shadow(shadowRadius: 8,
               shadowOffset: CGSize(width: 0, height: 2),
               shadowColor: .init(white: 0, alpha: 0.12))
    ]
    private static let levelThreeShadows: [Shadow] = [
        Shadow(shadowRadius: 2.5,
               shadowOffset: CGSize(width: 0, height: 0.5),
               shadowColor: .init(white: 0, alpha: 0.16)),
        Shadow(shadowRadius: 20,
               shadowOffset: CGSize(width: 0, height: 4),
               shadowColor: .init(white: 0, alpha: 0.2))
    ]
    private static let levelFourShadows: [Shadow] = [
        Shadow(shadowRadius: 14,
               shadowOffset: CGSize(width: 0, height: 4),
               shadowColor: .init(white: 0, alpha: 0.16)),
        Shadow(shadowRadius: 112,
               shadowOffset: CGSize(width: 0, height: 32),
               shadowColor: .init(white: 0, alpha: 0.2))
    ]
}
