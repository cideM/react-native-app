//
//  Typography+Definitions.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 02.06.23.
//

import UIKit

extension Typography {

    // MARK: - Design System defenitions: Finalized
    // MARK: Headers
    static let h1 = Typography(
        fontFamily: .lato,
        fontSize: .headerXL,
        fontWeight: .black,
        lineHeight: .s)
    static let h2 = Typography(
        fontFamily: .lato,
        fontSize: .headerL,
        fontWeight: .black,
        lineHeight: .s)
    static let h3 = Typography(
        fontFamily: .lato,
        fontSize: .headerM,
        fontWeight: .black,
        lineHeight: .s)
    static let h4 = Typography(
        fontFamily: .lato,
        fontSize: .headerS,
        fontWeight: .bold,
        lineHeight: .s)
    static let h5 = Typography(
        fontFamily: .lato,
        fontSize: .headerXS,
        fontWeight: .black,
        lineHeight: .m,
        letterSpacing: .s)
    static let h6 = Typography(
        fontFamily: .lato,
        fontSize: .textXS,
        fontWeight: .bold,
        lineHeight: .s,
        letterSpacing: .l)

    // MARK: Paragraphs
    static let paragraph = Typography(
        fontFamily: .lato,
        fontSize: .textM,
        fontWeight: .regular,
        lineHeight: .m,
        paragraphSpacing: .m)
    static let paragraphSmall = Typography(
        fontFamily: .lato,
        fontSize: .textS,
        fontWeight: .regular,
        lineHeight: .m,
        letterSpacing: .s)
    static let paragraphExtraSmall = Typography(
        fontFamily: .lato,
        fontSize: .textXS,
        fontWeight: .regular,
        lineHeight: .s,
        letterSpacing: .m)

    // MARK: - NON Design System defenitions
    static let h5Bold = Typography(
        fontFamily: .lato,
        fontSize: .headerXS,
        fontWeight: .bold,
        lineHeight: .s)
    static let button = Typography(
        fontFamily: .lato,
        fontSize: .textS, // used to be 15
        fontWeight: .black,
        lineHeight: .m)
    static let paragraphBold = Typography(
        fontFamily: .lato,
        fontSize: .textM,
        fontWeight: .bold,
        lineHeight: .m,
        paragraphSpacing: .m)
    static let paragraphSmallBold = Typography(
        fontFamily: .lato,
        fontSize: .textS,
        fontWeight: .bold,
        lineHeight: .m,
        letterSpacing: .s)
    static let paragraphExtraSmallBold = Typography(
        fontFamily: .lato,
        fontSize: .textXS,
        fontWeight: .bold,
        lineHeight: .m,
        letterSpacing: .m)
}
