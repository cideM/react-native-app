//
//  Color+Value.swift
//  Common
//
//  Created by Roberto Seidenberg on 30.09.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import DesignSystem

extension Color {

    var value: UIColor {
        switch self {
        case .brand32: return .backgroundAccent // UIColor(hex: 0x078391)
        case .brand66: return .backgroundAccentSubtle // UIColor(hex: 0x84D3DC)
        case .brandMain38: return .iconBrand // UIColor(hex: 0x0AA7B9)
        case .brand61: return .borderAccentSubtle // UIColor(hex: 0x63C7D2)
        case .brandLight3: return .borderAccentSubtle // UIColor(hex: 0xE7F6F8)
        case .black: return .backgroundBackdrop // UIColor(hex: 0x000000)
        case .black11: return  .textSecondary // UIColor(hex: 0x1A1C1C)
        case .white: return .textOnAccent // WHITE
        case .nearWhite: return .backgroundSecondary // UIColor(hex: 0xF8FAFC)
        case .gray: return .backgroundTransparentSelected // UIColor(hex: 0x888888)
        case .gray15: return .backgroundContrast // UIColor(hex: 0x314554)
        case .gray25: return .backgroundContrast // UIColor(hex: 0x364149)
        case .gray35: return .iconSecondary // UIColor(hex: 0x4C5B66)
        case .gray40: return .backgroundTransparentSelected // UIColor(hex: 0x607585)
        case .gray45: return .backgroundTransparentSelected // UIColor(hex: 0x627583)
        case .gray55: return .backgroundTransparentSelected // UIColor(hex: 0x7B8E9D)
        case .gray65: return .borderPrimary // UIColor(hex: 0x99A7B3)
        case .gray73: return .borderPrimary // UIColor(hex: 0xAEB9C6)
        case .gray80: return .dividerPrimary // UIColor(hex: 0xC3CBD5)
        case .gray95: return .canvas // UIColor(hex: 0xEEF2F5)
        case .gray96: return .canvas // UIColor(hex: 0xF1F3F4)
        case .grayDesaturated80: return .dividerPrimary // UIColor(hex: 0xC9CCCE)
        case .fontGray: return .iconSecondary // UIColor(hex: 0x3D4A54)
        case .lightGray: return .borderPrimary // UIColor(hex: 0xAAAAAA)
        case .grayLight01: return .borderPrimary // UIColor(hex: 0xA3B2BD)
        case .grayLight02: return .dividerPrimary // UIColor(hex: 0xE0E6EB)
        case .grayLight04: return .backgroundSecondary // UIColor(hex: 0xF5F7F9)
        case .grayRegular: return .backgroundTransparentSelected // UIColor(hex: 0x617585)
        case .darkGray: return .iconSecondary // UIColor(hex: 0x555555)
        case .grayDark01: return .iconSecondary // UIColor(hex: 0x40515E)
        case .grayDark02: return .iconPrimary // UIColor(hex: 0x191C1C)
        case .grayBlue: return .borderSecondary // UIColor(hex: 0x7A95AA)
        case .greenDark01: return .backgroundSuccess // UIColor(hex: 0x0B8363)
        case .green20: return .textSuccess // UIColor(hex: 0x075E46)
        case .green37: return .backgroundAccent // UIColor(hex: 0x0FA980)
        case .lightGreen3: return .backgroundSuccessSubtle // return UIColor(hex: 0xE8F8F4)
        case .lightRed3: return .backgroundErrorSubtle // UIColor(hex: 0xFDE8E8)
        case .red42: return .textError // UIColor(hex: 0x983E3E)
        case .red65: return .backgroundError // UIColor(hex: 0xEE6160)
        case .redLight01: return .borderError // return UIColor(hex: 0xF07575)
        case .nightBlackDark01: return .iconPrimary // return UIColor(hex: 0x24282D)
        case .blueGradient1: return .borderAccentSubtle // return UIColor(hex: 0x6AC2CC)
        case .blueGradient2: return .dividerPrimary // UIColor(hex: 0xBDDBEB)
        case .blue: return .backgroundInfo // UIColor(hex: 0x0000FF)
        case .transparent: return UIColor.clear
        // NEW ADDED VALUES
        case .textPrimary: return .textPrimary
        case .textSecondary: return .textSecondary
        case .textTertiary: return .textTertiary
        case .textAccent: return .textAccent
        case .textOnAccent: return .textOnAccent
        }
    }
}
