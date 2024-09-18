//
//  UIColor+Conversion.swift
//  Common
//
//  Created by Maksim Tuzhilin on 26.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    var hexValue: String {
        if cgColor.colorSpace?.model != .rgb {
            return "#FFFFFF"
        }

        guard let components = cgColor.components, components.count == 4 else {
            return "#FFFFFF"
        }

        return String(format: "#%02X%02X%02X", Int(components[0] * 255.0), Int(components[1] * 255.0), Int(components[2] * 255.0))
    }

    convenience init(hex: UInt64, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0

        self.init( red: red, green: green, blue: blue, alpha: alpha)
    }
}
