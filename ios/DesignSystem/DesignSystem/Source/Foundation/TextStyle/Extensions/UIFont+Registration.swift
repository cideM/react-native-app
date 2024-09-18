//
//  UIFont+Registration.swift
//  DesignSystem
//
//  Created by Elmar Tampe on 02.06.23.
//

import UIKit

extension UIFont {
    private static func registerFont(with name: String, fileExtension: String) {
        let frameworkBundle = Bundle(for: DesignSystem.self)
        let pathForResourceString = frameworkBundle.path(forResource: name, ofType: fileExtension)
        let fontData = NSData(contentsOfFile: pathForResourceString!) // swiftlint:disable:this force_unwrapping
        let dataProvider = CGDataProvider(data: fontData!) // swiftlint:disable:this force_unwrapping
        let fontRef = CGFont(dataProvider!) // swiftlint:disable:this force_unwrapping
        var errorRef: Unmanaged<CFError>?

        if CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false { // swiftlint:disable:this force_unwrapping
            print("Error registering font: \(String(describing: errorRef))") // swiftlint:disable:this disable_print
        }
    }

    private static func unregisterFont(with name: String, fileExtension: String) {
        let frameworkBundle = Bundle(for: DesignSystem.self)
        let pathForResourceString = frameworkBundle.path(forResource: name, ofType: fileExtension)
        let fontData = NSData(contentsOfFile: pathForResourceString!) // swiftlint:disable:this force_unwrapping
        let dataProvider = CGDataProvider(data: fontData!) // swiftlint:disable:this force_unwrapping
        let fontRef = CGFont(dataProvider!) // swiftlint:disable:this force_unwrapping
        var errorRef: Unmanaged<CFError>?

        if CTFontManagerUnregisterGraphicsFont(fontRef!, &errorRef) == false { // swiftlint:disable:this force_unwrapping
            // swiftlint:disable:next disable_print
            print("Error registering font: \(String(describing: errorRef))")
        }
    }

    static func registerCustomFonts() {
        for family in FontFamily.allCases {
            for fontVariation in family.rawValue.variations {
                registerFont(with: fontVariation, fileExtension: "ttf")
            }
        }
    }

    static func unregisterCustomFonts() {
        for family in FontFamily.allCases {
            for fontVariation in family.rawValue.variations {
                unregisterFont(with: fontVariation, fileExtension: "ttf")
            }
        }
    }
}
