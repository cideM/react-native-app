//  UIApplication+Convenience.swift
//
//  DesignSytemPreview
//
//  Created by Roberto Seidenberg on 21.12.23.
//

import UIKit

public extension UIApplication {

    // MARK: - KeyWindow

    // Taken from here:
    // https://stackoverflow.com/questions/68387187/how-to-use-uiwindowscene-windows-on-ios-15
    var keyWindow: UIWindow? {
        // Get connected scenes
        // Keep only active scenes, onscreen and visible to the user
        // Keep only the first `UIWindowScene`
        self.connectedScenes.first(where: { $0 is UIWindowScene && $0.activationState == .foregroundActive })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }

    static var activeKeyWindow: UIWindow? {
        UIApplication.shared.keyWindow
    }

    // MARK: - Windows
    var windows: [UIWindow] {
        // Get connected scenes
        // Keep only active scenes, onscreen and visible to the user
        // Keep only the first `UIWindowScene`
        self.connectedScenes.first(where: { $0 is UIWindowScene && $0.activationState == .foregroundActive })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows ?? []
    }
}
