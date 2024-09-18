//
//  UIColor+Convenience.swift
//  DesignSystemPreview
//
//  Created by Roberto Seidenberg on 04.04.23.
//

import UIKit

extension UIColor {

    // Taken from here and modified:
    // https://stackoverflow.com/questions/26341008/how-to-convert-uicolor-to-hex-and-display-in-nslog
    var hexString: String {
        let components = cgColor.components ?? []
        var r: CGFloat = 0
        if components.count > 0 { r = components[0] }
        var g: CGFloat = 0
        if components.count > 1 { g = components[1] }
        var b: CGFloat = 0
        if components.count > 2 { b = components[2] }

        let hexString = String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
     }
}
