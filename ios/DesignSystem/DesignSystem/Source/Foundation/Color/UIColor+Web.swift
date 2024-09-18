//
//  UIColor+Web.swift
//  DesignSystem
//
//  Created by Roberto Seidenberg on 25.09.23.
//

import UIKit

// Taken from here and modified: https://stackoverflow.com/a/28697136
public extension UIColor {

    func cssRGBA(style: UIUserInterfaceStyle?) -> String {
        let resolved = self.resolvedColor(with: .init(userInterfaceStyle: style ?? .light))
        let rgba = resolved.rgba()
        let r = Int(round(rgba.r * 255))
        let g = Int(round(rgba.g * 255))
        let b = Int(round(rgba.b * 255))
        let a = Int(round(rgba.a * 255))

        let css = String(format: "#%02x%02x%02x%02x", r, g, b, a)
        return css
    }
}

fileprivate extension UIColor {

    func rgba() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) { // swiftlint:disable:this large_tuple
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r, g, b, a)
        }
        return (r: 0, g: 0, b: 0, a: 0)
    }
}
