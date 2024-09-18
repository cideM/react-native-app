//
//  UIApplication+Static.swift
//  Knowledge
//
//  Created by Elmar Tampe on 10.03.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation

public extension UIApplication {

    static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)? .windows ?? [] }
            .first { $0.isKeyWindow }?.rootViewController
    }

    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)? .windows ?? [] }
            .first { $0.isKeyWindow }
    }

    static var style: UIUserInterfaceStyle? {
        rootViewController?.traitCollection.userInterfaceStyle
    }
}
