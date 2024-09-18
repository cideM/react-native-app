//
//  Font.swift
//  Common
//
//  Created by CSH on 30.01.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

// swiftlint:disable disable_print

import Foundation
import UIKit

/// All Fonts used in Amboss apps.
/// Ususally, instead of using a Font directly, a FontStyle should be used.
public enum Font: CaseIterable {
    case regular
    case bold
    case italic
    case black
    case medium
    case heavy
}

public extension Font {
    func font(withSize size: CGFloat) -> UIFont {
        let descriptor = self.descriptor(withSize: size)
        return UIFont(descriptor: descriptor, size: size)
    }

    func font(withTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        let size = self.size(forTextStyle: textStyle)
        return font(withSize: size)
    }

    private func descriptor(withSize size: CGFloat) -> UIFontDescriptor {
        UIFontDescriptor(name: name, size: size)
    }

    private func size(forTextStyle textStyle: UIFont.TextStyle) -> CGFloat {
        UIFont.preferredFont(forTextStyle: textStyle).pointSize
    }
}

public extension Font {
    /// Name of the font
    var name: String {
        switch self {
        case .regular: return "Lato-Regular"
        case .bold: return "Lato-Bold"
        case .italic: return "Lato-Italic"
        case .black: return "Lato-Black"
        case .medium: return "Lato-Medium"
        case .heavy: return "Lato-Heavy"
        }
    }

    /// Filename of the font
    var fileName: String {
        switch self {
        case .regular: return "Lato-Regular.ttf"
        case .bold: return "Lato-Bold.ttf"
        case .italic: return "Lato-Italic.ttf"
        case .black: return "Lato-Black.ttf"
        case .medium: return "Lato-Medium.ttf"
        case .heavy: return "Lato-Heavy.ttf"
        }
    }

    // Source URL for the font in the Commom framework
    var sourceUrl: URL {
        let bundle = Bundle(for: EmptyClass.self)
        guard let path = bundle.path(forResource: fileName, ofType: nil) else {
            preconditionFailure("Couldn't find the path for font \(name) in \(bundle)")
        }
        return URL(fileURLWithPath: path)
    }
}
