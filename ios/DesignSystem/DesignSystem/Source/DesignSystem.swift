//
//  DesignSystem.swift
//  DesignSystem
//
//  Created by Manaf Alabd Alrahim on 30.08.23.
//

import UIKit

public class DesignSystem {
    public static func initialize() {
        UIFont.registerCustomFonts()
    }

    public static func deinitialize() {
        UIFont.unregisterCustomFonts()
    }
}
